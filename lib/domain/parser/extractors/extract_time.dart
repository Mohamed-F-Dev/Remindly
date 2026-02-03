import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class TimeExtractor implements Extractors {
  static final _spaces = RegExp(r'\s+');

  // ======================
  // Period words
  // ======================
  static final _amWords = RegExp(r'(صباح|فجر|بدري)', caseSensitive: false);
  static final _pmWords = RegExp(
    r'(مساء|بالليل|ليل|عصر|مغرب|عشاء|ظهر|بعد\s+الظهر)',
    caseSensitive: false,
  );

  // ======================
  // Core patterns
  // ======================
  static final _numericTime = RegExp(r'(?<!\S)(\d{1,2})(?::(\d{2}))?(?!\S)');

  static final _hourWord = RegExp(
    r'(الساعة|الساعه)?\s*(واحده|واحدة|اتنين|اثنين|تلاته|ثلاثه|اربعه|أربعه|خمسه|خمسة|سته|ستة|سبعه|سبعة|تمانيه|ثمانيه|تسعه|تسعة|عشره|عشرة|حداشر|احداشر|اتناشر|اثناشر)',
  );

  static final _half = RegExp(r'(ونص)');
  static final _quarter = RegExp(r'(وربع)');
  static final _third = RegExp(r'(وتلت|وثلث)');
  static final _minusQuarter = RegExp(r'(الا\s*ربع|إلا\s*ربع)');
  static final _minusMinutes = RegExp(r'(الا\s*(\d{1,2}))');

  // ======================
  // Entry
  // ======================
  @override
  void apply(ParseContext ctx) {
    var s = ctx.text;

    final period = _detectPeriod(s);

    // 1️⃣ Numeric time (5 / 5:30)
    final numeric = _numericTime.firstMatch(s);
    if (numeric != null) {
      var h = int.parse(numeric.group(1)!);
      var m = numeric.group(2) != null ? int.parse(numeric.group(2)!) : 0;

      final mod = _applyMinuteModifiers(s, h, m);
      h = mod.h;
      m = mod.m;

      final fixed = _fixWithPeriod(h, m, period);
      if (fixed != null) {
        _commit(ctx, s, numeric.group(0)!, fixed);
        return;
      }
    }

    // 2️⃣ Word-based hour (خمسة / سبعة ونص)
    final word = _hourWord.firstMatch(s);
    if (word != null) {
      final h0 = _wordToHour(word.group(2)!);
      if (h0 != null) {
        var h = h0;
        var m = 0;

        final mod = _applyMinuteModifiers(s, h, m);
        h = mod.h;
        m = mod.m;

        final fixed = _fixWithPeriod(h, m, period);
        if (fixed != null) {
          _commit(ctx, s, word.group(0)!, fixed);
          return;
        }
      }
    }

    // 3️⃣ Period only (الصبح / العصر)
    final defaultByPeriod = _defaultTimeFromPeriod(period);
    if (defaultByPeriod != null) {
      ctx.time = defaultByPeriod;
      ctx.tokens.add(Token(ExtractKind.time, period!));
      ctx.text = _clean(s.replaceAll(_amWords, ' ').replaceAll(_pmWords, ' '));
      return;
    }

    ctx.text = _clean(s);
  }

  // ======================
  // Helpers
  // ======================

  void _commit(ParseContext ctx, String s, String raw, ({int h, int m}) time) {
    ctx.time = time;
    ctx.tokens.add(Token(ExtractKind.time, raw));
    ctx.text = _clean(
      s
          .replaceAll(raw, ' ')
          .replaceAll(_amWords, ' ')
          .replaceAll(_pmWords, ' '),
    );
  }

  ({int h, int m}) _applyMinuteModifiers(String s, int h, int m) {
    if (_half.hasMatch(s)) return (h: h, m: 30);
    if (_quarter.hasMatch(s)) return (h: h, m: 15);
    if (_third.hasMatch(s)) return (h: h, m: 20);

    final minusQ = _minusQuarter.firstMatch(s);
    if (minusQ != null) return (h: h - 1, m: 45);

    final minusM = _minusMinutes.firstMatch(s);
    if (minusM != null) {
      final d = int.parse(minusM.group(2)!);
      return (h: h - 1, m: 60 - d);
    }

    return (h: h, m: m);
  }

  String? _detectPeriod(String s) {
    if (_pmWords.hasMatch(s)) return 'pm';
    if (_amWords.hasMatch(s)) return 'am';
    return null;
  }

  ({int h, int m})? _fixWithPeriod(int h, int m, String? period) {
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;

    if (h > 12) return (h: h, m: m);

    if (period == 'pm') return (h: h == 12 ? 12 : h + 12, m: m);
    if (period == 'am') return (h: h == 12 ? 0 : h, m: m);

    // Default UX: evening
    return (h: h < 7 ? h + 12 : h, m: m);
  }

  ({int h, int m})? _defaultTimeFromPeriod(String? period) {
    switch (period) {
      case 'am':
        return (h: 9, m: 0);
      case 'pm':
        return (h: 20, m: 0);
    }
    return null;
  }

  int? _wordToHour(String w) {
    const map = {
      'واحده': 1,
      'واحدة': 1,
      'اتنين': 2,
      'اثنين': 2,
      'تلاته': 3,
      'ثلاثه': 3,
      'اربعه': 4,
      'أربعه': 4,
      'خمسه': 5,
      'خمسة': 5,
      'سته': 6,
      'ستة': 6,
      'سبعه': 7,
      'سبعة': 7,
      'تمانيه': 8,
      'ثمانيه': 8,
      'تسعه': 9,
      'تسعة': 9,
      'عشره': 10,
      'عشرة': 10,
      'حداشر': 11,
      'احداشر': 11,
      'اتناشر': 12,
      'اثناشر': 12,
    };
    return map[w];
  }

  String _clean(String s) => s.replaceAll(_spaces, ' ').trim();
}

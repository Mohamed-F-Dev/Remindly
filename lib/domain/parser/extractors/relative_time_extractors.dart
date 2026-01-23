import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class RelativeTimeExtractor implements Extractors {
  // ==============
  // Compiled regex
  // ==============
  static final _spaces = RegExp(r'\s+');

  // Intent trigger (قبل/بعد)
  static final _trigger = RegExp(
    r'(?<!\S)(و)?\s*(فكرني|فكّرني|ذكرني|ذكّرني|نبهني|نبّهني)(?!\S)',
  );

  // After-like words (تقوم مقام "بعد")
  static final _afterLike = RegExp(r'(?<!\S)(بعد|كمان|خلال|بعدها)(?!\S)');

  // Arabic digits
  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  // --- Fixed pieces ---
  static final _halfHour = RegExp(r'(?<!\S)(نص\s*ساعه|نص\s*ساعة)(?!\S)');
  static final _quarterHour = RegExp(r'(?<!\S)(ربع\s*ساعه|ربع\s*ساعة)(?!\S)');
  static final _thirdHour = RegExp(
    r'(?<!\S)(تلت\s*ساعه|تلت\s*ساعة|ثلث\s*ساعه|ثلث\s*ساعة)(?!\S)',
  );

  static final _twoHours = RegExp(r'(?<!\S)(ساعتين|ساعتان)(?!\S)');
  static final _oneHour = RegExp(r'(?<!\S)(ساعه|ساعة)(?!\S)');

  static final _twoDays = RegExp(r'(?<!\S)(يومين|يومان)(?!\S)');
  static final _oneDay = RegExp(r'(?<!\S)(يوم)(?!\S)');

  static final _twoWeeks = RegExp(r'(?<!\S)(اسبوعين|أسبوعين)(?!\S)');
  static final _oneWeek = RegExp(r'(?<!\S)(اسبوع|أسبوع)(?!\S)');

  // --- Number + unit ---
  static final _nMinutes = RegExp(
    r'(?<!\S)(\d+)\s*(دقيقه|دقيقة|دقايق|دقائق|د)(?!\S)',
  );
  static final _nHours = RegExp(r'(?<!\S)(\d+)\s*(ساعه|ساعة|ساعات|س)(?!\S)');
  static final _nDays = RegExp(r'(?<!\S)(\d+)\s*(يوم|ايام|أيام)(?!\S)');
  static final _nWeeks = RegExp(
    r'(?<!\S)(\d+)\s*(اسبوع|أسبوع|اسابيع|أسابيع)(?!\S)',
  );
  static final _nMonths = RegExp(r'(?<!\S)(\d+)\s*(شهر|شهور|أشهر)(?!\S)');
  static final _nYears = RegExp(r'(?<!\S)(\d+)\s*(سنه|سنة|سنين|سنوات)(?!\S)');

  // --- Compound: ساعة ونص / ساعة وربع / ساعتين نص ساعة (بدون و) ---
  static final _hourAndHalf = RegExp(
    r'(?<!\S)(ساعه|ساعة|ساعتين|ساعتان)\s*(و)?\s*نص(?!\S)',
  );
  static final _hourAndQuarter = RegExp(
    r'(?<!\S)(ساعه|ساعة|ساعتين|ساعتان)\s*(و)?\s*ربع(?!\S)',
  );
  static final _hourAndThird = RegExp(
    r'(?<!\S)(ساعه|ساعة|ساعتين|ساعتان)\s*(و)?\s*(تلت|ثلث)(?!\S)',
  );

  // fillers common in speech
  static final _fillers = RegExp(r'(?<!\S)(كده|يعني|بس)(?!\S)');

  @override
  void apply(final ParseContext ctx) {
    final original = ctx.text;
    var s = ctx.text;

    // final hasSignal = _trigger.hasMatch(s) || _afterLike.hasMatch(s);
    // if (!hasSignal) {
    //   ctx.text = _clean(original);
    //   return;
    // }

    // نجمع و"نستهلك" matches من النص (عشان ما يحصلش double count)
    var total = Duration.zero;
    final extractedPhrases = <String>[];

    bool consume(final RegExp r, final Duration d) {
      final m = r.firstMatch(s);
      if (m == null) return false;
      extractedPhrases.add(m.group(0)!);
      total += d;
      s = _clean(s.replaceRange(m.start, m.end, ' '));
      return true;
    }

    bool consumeNumber(final RegExp r, final Duration Function(int) calc) {
      final m = r.firstMatch(s);
      if (m == null) return false;
      final n = int.tryParse(m.group(1)!) ?? 0;
      if (n <= 0) return false;
      extractedPhrases.add(m.group(0)!);
      total += calc(n);
      s = _clean(s.replaceRange(m.start, m.end, ' '));
      return true;
    }

    // 1) Compounds أولاً (عشان ما تتحسبش كقطع)
    while (true) {
      if (consume(_hourAndHalf, const Duration(minutes: 90))) continue;
      if (consume(_hourAndQuarter, const Duration(minutes: 75))) continue;
      if (consume(_hourAndThird, const Duration(minutes: 80))) continue;
      break;
    }

    // 2) Fixed words (ساعتين/نص ساعة/ربع ساعة..)
    while (true) {
      if (consume(_twoHours, const Duration(hours: 2))) continue;
      if (consume(_oneHour, const Duration(hours: 1))) continue;

      if (consume(_halfHour, const Duration(minutes: 30))) continue;
      if (consume(_quarterHour, const Duration(minutes: 15))) continue;
      if (consume(_thirdHour, const Duration(minutes: 20))) continue;

      if (consume(_twoDays, const Duration(days: 2))) continue;
      if (consume(_oneDay, const Duration(days: 1))) continue;

      if (consume(_twoWeeks, const Duration(days: 14))) continue;
      if (consume(_oneWeek, const Duration(days: 7))) continue;

      break;
    }

    // 3) Number + unit (loop عشان “10 دقايق 5 دقايق”)
    while (true) {
      if (consumeNumber(_nMinutes, (final n) => Duration(minutes: n))) continue;
      if (consumeNumber(_nHours, (final n) => Duration(hours: n))) continue;
      if (consumeNumber(_nDays, (final n) => Duration(days: n))) continue;
      if (consumeNumber(_nWeeks, (final n) => Duration(days: n * 7))) continue;
      if (consumeNumber(_nMonths, (final n) => Duration(days: n * 30)))
        continue;
      if (consumeNumber(_nYears, (final n) => Duration(days: n * 365)))
        continue;
      break;
    }

    if (total == Duration.zero) {
      // مفيش مدة اتلقطت
      ctx.text = _clean(original);
      return;
    }

    // ✅ Commit
    ctx.relative = total;
    // نحفظ اللي اتشاف فعلاً (مش النص كله)
    for (final p in extractedPhrases) {
      ctx.tokens.add(Token(ExtractKind.relative, p));
    }

    // ✅ مهم: نشيل اللي اتستخرج من ctx.text (بالـ normalized الناتج)
    // لو ctx.text بيتستخدم بس للتحليل الداخلي، ده أفضل وأضمن.

    ctx.text = s;
  }

  // =========================
  // Normalization (Voice-safe)
  // =========================

  static String _clean(final String s) => s.replaceAll(_spaces, ' ').trim();
}

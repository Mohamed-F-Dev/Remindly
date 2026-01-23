import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class TimeExtractor implements Extractors {
  static final RegExp _periodWordsRegex = RegExp(
    r'(صباحًا|صباحا|صباح|مساءً|مساء|بالليل|ليل|فجر|الظهر|ظهر|عصر|مغرب|عشاء|بعد\s+الظهر)',
  );

  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;

    // (0) حدّد AM/PM من كلمات الفترة
    final period = _detectPeriod(s); // am/pm/null

    // (1) "الساعة 5" / "الساعه 5:30" (هيمسك حتى لو قبلها "في")
    final hourPhrase = RegExp(
      r'(الساعة|الساعه)\s+(\d{1,2})(?::(\d{1,2}))?',
    ).firstMatch(s);

    if (hourPhrase != null) {
      final raw = hourPhrase.group(0)!;
      var h = int.parse(hourPhrase.group(2)!);
      var m = hourPhrase.group(3) != null ? int.parse(hourPhrase.group(3)!) : 0;

      final fixed = _fixHourWithPeriod(h, m, period);
      if (fixed != null) {
        ctx.time = (h: fixed.$1, m: fixed.$2);
        ctx.tokens.add(Token(ExtractKind.time, raw));

        ctx.text = _cleanSpaces(
          s.replaceAll(raw, ' ').replaceAll(_periodWordsRegex, ' '),
        );
        return;
      }
    }

    // (2) "5:30"
    final numeric = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(s);
    if (numeric != null) {
      final raw = numeric.group(0)!;
      final h = int.parse(numeric.group(1)!);
      final m = int.parse(numeric.group(2)!);

      final fixed = _fixHourWithPeriod(h, m, period);
      if (fixed != null) {
        ctx.time = (h: fixed.$1, m: fixed.$2);
        ctx.tokens.add(Token(ExtractKind.time, raw));

        ctx.text = _cleanSpaces(
          s.replaceAll(raw, ' ').replaceAll(_periodWordsRegex, ' '),
        );
        return;
      }
    }

    // (3) "خمسه" / "سبعه ونص" ... (أساسيات)
    final wordTime = RegExp(
      r'(الساعة|الساعه)?\s*(واحده|واحدة|اتنين|اثنين|تلاته|ثلاثه|اربعه|أربعه|خمسه|خمسة|سته|ستة|سبعه|سبعة|تمانيه|ثمانيه|تسعه|تسعة|عشره|عشرة|حداشر|احداشر|اتناشر|اثناشر)(\s+ونص)?',
    ).firstMatch(s);

    if (wordTime != null) {
      final raw = wordTime.group(0)!.trim();
      final hourWord = wordTime.group(2)!;
      final hasHalf = wordTime.group(3) != null;

      final h0 = _arabicWordToHour(hourWord);
      if (h0 != null) {
        final h = h0;
        final m = hasHalf ? 30 : 0;

        final fixed = _fixHourWithPeriod(h, m, period);
        if (fixed != null) {
          ctx.time = (h: fixed.$1, m: fixed.$2);
          ctx.tokens.add(Token(ExtractKind.time, raw));

          ctx.text = _cleanSpaces(
            s.replaceAll(raw, ' ').replaceAll(_periodWordsRegex, ' '),
          );
          return;
        }
      }
    }

    ctx.text = _cleanSpaces(s);
  }

  String? _detectPeriod(final String s) {
    // pm-ish
    if (RegExp(
      r'(مساءً|مساء|بالليل|ليل|عشاء|مغرب|بعد\s+الظهر|عصر|الظهر|ظهر)',
    ).hasMatch(s)) {
      return 'pm';
    }
    // am-ish
    if (RegExp(r'(صباحًا|صباحا|صباح|فجر)').hasMatch(s)) {
      return 'am';
    }
    return null;
  }

  (int, int)? _fixHourWithPeriod(int h, final int m, final String? period) {
    if (h < 0 || h > 23) return null;
    if (m < 0 || m > 59) return null;

    if (h > 12) return (h, m);

    if (period == 'pm') {
      if (h < 12) h += 12;
      return (h, m);
    }

    if (period == 'am') {
      if (h == 12) h = 0;
      return (h, m);
    }

    return (h, m);
  }

  int? _arabicWordToHour(final String w) {
    switch (w) {
      case 'واحده':
      case 'واحدة':
        return 1;
      case 'اتنين':
      case 'اثنين':
        return 2;
      case 'تلاته':
      case 'ثلاثه':
        return 3;
      case 'اربعه':
      case 'أربعه':
        return 4;
      case 'خمسه':
      case 'خمسة':
        return 5;
      case 'سته':
      case 'ستة':
        return 6;
      case 'سبعه':
      case 'سبعة':
        return 7;
      case 'تمانيه':
      case 'ثمانيه':
        return 8;
      case 'تسعه':
      case 'تسعة':
        return 9;
      case 'عشره':
      case 'عشرة':
        return 10;
      case 'حداشر':
      case 'احداشر':
        return 11;
      case 'اتناشر':
      case 'اثناشر':
        return 12;
    }
    return null;
  }

  String _cleanSpaces(final String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

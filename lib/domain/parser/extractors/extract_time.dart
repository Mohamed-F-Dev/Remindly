import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class TimeExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;

    // (0) حدّد AM/PM من كلمات الفترة
    final period = _detectPeriod(s); // am/pm/null

    // ------------------------------------------------------------
    // (1) صيغة الساعة: "الساعة 5" / "الساعه 5:30"
    // ------------------------------------------------------------
    final hourPhrase = RegExp(
      r'\b(الساعة|الساعه)\s+(\d{1,2})(?::(\d{1,2}))?\b',
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
          s
              .replaceAll(raw, ' ')
              .replaceAll(
                RegExp(
                  r'\b(صباح|مساء|بالليل|ليل|فجر|الظهر|ظهر|عصر|مغرب|عشاء|بعد\s+الظهر)\b',
                ),
                ' ',
              ),
        );
        return;
      }
    }

    // ------------------------------------------------------------
    // (2) صيغة رقمية: "5:30"
    // ------------------------------------------------------------
    final numeric = RegExp(r'\b(\d{1,2}):(\d{2})\b').firstMatch(s);
    if (numeric != null) {
      final raw = numeric.group(0)!;
      final h = int.parse(numeric.group(1)!);
      final m = int.parse(numeric.group(2)!);

      final fixed = _fixHourWithPeriod(h, m, period);
      if (fixed != null) {
        ctx.time = (h: fixed.$1, m: fixed.$2);
        ctx.tokens.add(Token(ExtractKind.time, raw));
        ctx.text = _cleanSpaces(
          s
              .replaceAll(raw, ' ')
              .replaceAll(
                RegExp(
                  r'\b(صباح|مساء|بالليل|ليل|فجر|الظهر|ظهر|عصر|مغرب|عشاء|بعد\s+الظهر)\b',
                ),
                ' ',
              ),
        );
        return;
      }
    }

    // ------------------------------------------------------------
    // (3) أرقام بالكلام (أساسيات): "خمسة" / "خمسه" / "سبعة ونص"
    // ------------------------------------------------------------
    final wordTime = RegExp(
      r'\b(الساعة|الساعه)?\s*(واحده|واحدة|اتنين|اثنين|تلاته|ثلاثه|اربعه|أربعه|خمسه|خمسة|سته|ستة|سبعه|سبعة|تمانيه|ثمانيه|تسعه|تسعة|عشره|عشرة|حداشر|احداشر|اتناشر|اثناشر)\b(\s+ونص)?\b',
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
            s
                .replaceAll(raw, ' ')
                .replaceAll(
                  RegExp(
                    r'\b(صباح|مساء|بالليل|ليل|فجر|الظهر|ظهر|عصر|مغرب|عشاء|بعد\s+الظهر)\b',
                  ),
                  ' ',
                ),
          );
          return;
        }
      }
    }

    ctx.text = _cleanSpaces(s);
  }

  /// يرجّع "am" أو "pm" أو null
  String? _detectPeriod(final String s) {
    // pm-ish
    if (RegExp(r'\b(مساء|بالليل|ليل|عشاء|مغرب|بعد\s+الظهر|عصر)\b').hasMatch(s))
      return 'pm';
    // am-ish
    if (RegExp(r'\b(صباح|فجر)\b').hasMatch(s)) return 'am';
    // الظهر غالبًا 12-2 pm
    if (RegExp(r'\b(الظهر|ظهر)\b').hasMatch(s)) return 'pm';
    return null;
  }

  /// يحوّل ساعة/دقيقة إلى 24h مع مراعاة period
  /// يرجع (hour, minute) أو null لو قيم غير صالحة
  (int, int)? _fixHourWithPeriod(int h, final int m, final String? period) {
    if (h < 0 || h > 23) return null;
    if (m < 0 || m > 59) return null;

    // لو المستخدم كتب 0..23 بصراحة نخليها كما هي
    if (h > 12) return (h, m);

    // لو period موجود:
    if (period == 'pm') {
      if (h < 12) h += 12;
      return (h, m);
    }

    if (period == 'am') {
      if (h == 12) h = 0;
      return (h, m);
    }

    // لو مفيش period: نخليها كما هي (resolver يقرر النهارده/بكرة)
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

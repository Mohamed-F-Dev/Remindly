import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class DateExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;
    final today = DateTime(ctx.now.year, ctx.now.month, ctx.now.day);

    // ------------------------------------------------------------
    // (1) كلمات ثابتة
    // ------------------------------------------------------------
    if (_matchAndSet(ctx, s, RegExp(r'\b(النهارده|اليوم|نهارده)\b'), today)) {
      ctx.text = _cleanSpaces(ctx.text);
      return;
    }

    // بعد بكرة / بكرة (normalized: بكرة -> بكره ، جمعة -> جمعه)
    if (_matchAndSet(
      ctx,
      s,
      RegExp(r'\b(بعد\s+بكره)\b'),
      today.add(const Duration(days: 2)),
    )) {
      ctx.text = _cleanSpaces(ctx.text);
      return;
    }

    if (_matchAndSet(
      ctx,
      s,
      RegExp(r'\b(بكره)\b'),
      today.add(const Duration(days: 1)),
    )) {
      ctx.text = _cleanSpaces(ctx.text);
      return;
    }

    if (_matchAndSet(
      ctx,
      s,
      RegExp(r'\b(امبارح)\b'),
      today.subtract(const Duration(days: 1)),
    )) {
      ctx.text = _cleanSpaces(ctx.text);
      return;
    }

    // ------------------------------------------------------------
    // (2) أول/آخر الأسبوع/الشهر
    // ------------------------------------------------------------
    // أول الأسبوع: السبت (نقدر نخليها الاثنين لو حابب، لكن هنختار الاثنين كأشهر في العمل)
    // هنا هنستخدم "بداية الاسبوع" => الاثنين القادم/الحالي حسب اليوم
    final startWeekMatch = RegExp(
      r'\b(بدايه\s+الاسبوع|بداية\s+الاسبوع|اول\s+الاسبوع)\b',
    ).firstMatch(s);
    if (startWeekMatch != null) {
      final raw = startWeekMatch.group(0)!;
      final date = _nextOrSameWeekday(today, DateTime.monday, forceNext: false);
      ctx.date = DateTime(date.year, date.month, date.day);
      ctx.tokens.add(Token(ExtractKind.date, raw));
      ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
      return;
    }

    final endWeekMatch = RegExp(
      r'\b(نهايه\s+الاسبوع|نهاية\s+الاسبوع|اخر\s+الاسبوع|آخر\s+الاسبوع)\b',
    ).firstMatch(s);
    if (endWeekMatch != null) {
      final raw = endWeekMatch.group(0)!;
      final date = _nextOrSameWeekday(today, DateTime.sunday, forceNext: false);
      ctx.date = DateTime(date.year, date.month, date.day);
      ctx.tokens.add(Token(ExtractKind.date, raw));
      ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
      return;
    }

    final startMonthMatch = RegExp(
      r'\b(بدايه\s+الشهر|بداية\s+الشهر|اول\s+الشهر)\b',
    ).firstMatch(s);
    if (startMonthMatch != null) {
      final raw = startMonthMatch.group(0)!;
      final date = DateTime(today.year, today.month, 1);
      ctx.date = date;
      ctx.tokens.add(Token(ExtractKind.date, raw));
      ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
      return;
    }

    final endMonthMatch = RegExp(
      r'\b(نهايه\s+الشهر|نهاية\s+الشهر|اخر\s+الشهر|آخر\s+الشهر)\b',
    ).firstMatch(s);
    if (endMonthMatch != null) {
      final raw = endMonthMatch.group(0)!;
      final firstNextMonth = (today.month == 12)
          ? DateTime(today.year + 1, 1, 1)
          : DateTime(today.year, today.month + 1, 1);
      final date = firstNextMonth.subtract(const Duration(days: 1));
      ctx.date = DateTime(date.year, date.month, date.day);
      ctx.tokens.add(Token(ExtractKind.date, raw));
      ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
      return;
    }

    // ------------------------------------------------------------
    // (3) تاريخ رقمي: 12/3 أو 12/3/2026 أو 12-3-26
    // نفترض dd/mm (الأكثر شيوعًا عربيًا). لو عايز mm/dd قولّي.
    // ------------------------------------------------------------
    final numericDate = RegExp(
      r'\b(\d{1,2})[\/\-\.](\d{1,2})(?:[\/\-\.](\d{2,4}))?\b',
    ).firstMatch(s);
    if (numericDate != null) {
      final raw = numericDate.group(0)!;
      final d = int.parse(numericDate.group(1)!);
      final m = int.parse(numericDate.group(2)!);
      final yRaw = numericDate.group(3);

      final year = (yRaw == null)
          ? today.year
          : (yRaw.length == 2 ? (2000 + int.parse(yRaw)) : int.parse(yRaw));

      final parsed = _safeDate(year, m, d);
      if (parsed != null) {
        // لو من غير سنة وجت في الماضي → خليها السنة الجاية
        if (yRaw == null && parsed.isBefore(today)) {
          final nextYearParsed = _safeDate(today.year + 1, m, d);
          if (nextYearParsed != null) {
            ctx.date = nextYearParsed;
          } else {
            ctx.date = parsed;
          }
        } else {
          ctx.date = parsed;
        }

        ctx.tokens.add(Token(ExtractKind.date, raw));
        ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
        return;
      }
    }

    // ------------------------------------------------------------
    // (4) يوم + شهر عربي (+ سنة اختيارية)
    // مثال: 12 يناير 2026 / 12 يناير
    // (بعد normalization: يناير/فبراير... غالبًا ثابتة)
    // ------------------------------------------------------------
    final monthMap = <String, int>{
      'يناير': 1,
      'فبراير': 2,
      'مارس': 3,
      'ابريل': 4,
      'أبريل': 4,
      'مايو': 5,
      'يونيو': 6,
      'يوليو': 7,
      'اغسطس': 8,
      'أغسطس': 8,
      'سبتمبر': 9,
      'اكتوبر': 10,
      'أكتوبر': 10,
      'نوفمبر': 11,
      'ديسمبر': 12,
    };

    final arabicMonthDate = RegExp(
      r'\b(\d{1,2})\s+(يناير|فبراير|مارس|ابريل|أبريل|مايو|يونيو|يوليو|اغسطس|أغسطس|سبتمبر|اكتوبر|أكتوبر|نوفمبر|ديسمبر)(?:\s+(\d{4}))?\b',
    ).firstMatch(s);

    if (arabicMonthDate != null) {
      final raw = arabicMonthDate.group(0)!;
      final day = int.parse(arabicMonthDate.group(1)!);
      final monthName = arabicMonthDate.group(2)!;
      final yearStr = arabicMonthDate.group(3);

      final month = monthMap[monthName]!;
      final year = yearStr == null ? today.year : int.parse(yearStr);

      final parsed = _safeDate(year, month, day);
      if (parsed != null) {
        if (yearStr == null && parsed.isBefore(today)) {
          final nextYearParsed = _safeDate(today.year + 1, month, day);
          ctx.date = nextYearParsed ?? parsed;
        } else {
          ctx.date = parsed;
        }

        ctx.tokens.add(Token(ExtractKind.date, raw));
        ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
        return;
      }
    }

    // ------------------------------------------------------------
    // (5) الأسبوع الجاي/القادم (بدون يوم محدد) -> +7 أيام
    // ------------------------------------------------------------
    if (_matchAndSet(
      ctx,
      s,
      RegExp(r'\b(الاسبوع\s+(الجاي|القادم)|الاسبوع\s+اللي\s+جاي)\b'),
      today.add(const Duration(days: 7)),
    )) {
      ctx.text = _cleanSpaces(ctx.text);
      return;
    }

    // ------------------------------------------------------------
    // (6) يوم أسبوع (الجمعة/الجمعة الجاية...)
    // هنا هنخلي "الجمعة" = الجمعة القادمة دائمًا (أأمن)
    // ------------------------------------------------------------
    final weekdayMatch = RegExp(
      r'\b(يوم\s+)?(السبت|الاحد|الاثنين|الاتنين|الثلاثاء|الاربعاء|الخميس|الجمعه)(\s+(الجاي|القادم|اللي\s+جاي))?\b',
    ).firstMatch(s);

    if (weekdayMatch != null) {
      final raw = weekdayMatch.group(0)!;
      final dayWord = weekdayMatch.group(2)!;
      final hasNext = weekdayMatch.group(3) != null;

      final targetWeekday = _arabicWeekdayToDartWeekday(dayWord);
      if (targetWeekday != null) {
        // لو قال "الجاي" forceNext=true
        // لو ما قالش، برضه نخليها الجاية (forceNext=true) عشان أأمن
        final date = _nextOrSameWeekday(
          today,
          targetWeekday,
          forceNext: true || hasNext,
        );
        ctx.date = DateTime(date.year, date.month, date.day);
        ctx.tokens.add(Token(ExtractKind.date, raw));
        ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
        return;
      }
    }

    // ------------------------------------------------------------
    // (7) قبل/بعد + رقم + وحدة (أيام/أسابيع/شهور/سنين)
    // ده “تاريخ نسبي” لكن بنستخرج Date فقط
    // ------------------------------------------------------------
    final rel = RegExp(
      r'\b(بعد|قبل)\s+(\d+)\s+(يوم|ايام|أيام|اسبوع|أسبوع|اسابيع|أسابيع|شهر|شهور|أشهر|سنه|سنة|سنين|سنوات)\b',
    ).firstMatch(s);
    if (rel != null) {
      final raw = rel.group(0)!;
      final dir = rel.group(1)!; // بعد/قبل
      final n = int.tryParse(rel.group(2)!) ?? 0;
      final unit = rel.group(3)!;

      if (n > 0) {
        int days = 0;
        if (unit == 'يوم' || unit == 'ايام' || unit == 'أيام') {
          days = n;
        } else if (unit == 'اسبوع' ||
            unit == 'أسبوع' ||
            unit == 'اسابيع' ||
            unit == 'أسابيع') {
          days = n * 7;
        } else if (unit == 'شهر' || unit == 'شهور' || unit == 'أشهر') {
          days = n * 30; // تقريب
        } else {
          days = n * 365; // تقريب
        }

        final date = (dir == 'بعد')
            ? today.add(Duration(days: days))
            : today.subtract(Duration(days: days));
        ctx.date = DateTime(date.year, date.month, date.day);
        ctx.tokens.add(Token(ExtractKind.date, raw));
        ctx.text = _cleanSpaces(s.replaceAll(raw, ' '));
        return;
      }
    }

    ctx.text = _cleanSpaces(s);
  }

  int? _arabicWeekdayToDartWeekday(final String day) {
    switch (day) {
      case 'السبت':
        return DateTime.saturday;
      case 'الاحد':
        return DateTime.sunday;
      case 'الاثنين':
      case 'الاتنين':
        return DateTime.monday;
      case 'الثلاثاء':
        return DateTime.tuesday;
      case 'الاربعاء':
        return DateTime.wednesday;
      case 'الخميس':
        return DateTime.thursday;
      case 'الجمعه':
        return DateTime.friday;
    }
    return null;
  }

  DateTime _nextOrSameWeekday(
    final DateTime fromDate,
    final int targetWeekday, {
    required final bool forceNext,
  }) {
    final current = fromDate.weekday;
    var delta = (targetWeekday - current) % 7;
    if (delta == 0 && forceNext) delta = 7;
    return fromDate.add(Duration(days: delta));
  }

  bool _matchAndSet(
    final ParseContext ctx,
    final String s,
    final RegExp regex,
    final DateTime date,
  ) {
    final m = regex.firstMatch(s);
    if (m == null) return false;

    final raw = m.group(0)!;
    ctx.date = DateTime(date.year, date.month, date.day);
    ctx.tokens.add(Token(ExtractKind.date, raw));
    ctx.text = s.replaceAll(regex, ' ');
    return true;
  }

  DateTime? _safeDate(final int year, final int month, final int day) {
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;

    try {
      final dt = DateTime(year, month, day);
      // تأكد إن التاريخ ما اتعملش rollover (مثلاً 31/2)
      if (dt.year != year || dt.month != month || dt.day != day) return null;
      return DateTime(dt.year, dt.month, dt.day);
    } catch (_) {
      return null;
    }
  }

  String _cleanSpaces(final String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

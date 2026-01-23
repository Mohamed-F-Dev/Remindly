import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class DateExtractor implements Extractors {
  static final _spaces = RegExp(r'\s+');

  // Boundary عربي آمن
  static String _wb(final String p) => r'(?<!\S)' + p + r'(?!\S)';

  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;
    final today = DateTime(ctx.now.year, ctx.now.month, ctx.now.day);

    // ============================================================
    // (1) كلمات ثابتة: اليوم / بكرة / بعد بكرة / امبارح
    // ============================================================

    if (_matchAndSet(ctx, s, RegExp(_wb(r'(النهارده|اليوم|نهارده)')), today)) {
      ctx.text = _clean(ctx.text);
      return;
    }

    if (_matchAndSet(
      ctx,
      s,
      RegExp(_wb(r'(بعد\s+بكره)')),
      today.add(const Duration(days: 2)),
    )) {
      ctx.text = _clean(ctx.text);
      return;
    }

    if (_matchAndSet(
      ctx,
      s,
      RegExp(_wb(r'(بكره)')),
      today.add(const Duration(days: 1)),
    )) {
      ctx.text = _clean(ctx.text);
      return;
    }

    if (_matchAndSet(
      ctx,
      s,
      RegExp(_wb(r'(امبارح)')),
      today.subtract(const Duration(days: 1)),
    )) {
      ctx.text = _clean(ctx.text);
      return;
    }

    // ============================================================
    // (2) بداية / نهاية الأسبوع
    // ============================================================

    final startWeek = RegExp(
      _wb(r'(بدايه\s+الاسبوع|بداية\s+الاسبوع|اول\s+الاسبوع)'),
    ).firstMatch(s);
    if (startWeek != null) {
      final raw = startWeek.group(0)!;
      final date = _nextOrSameWeekday(today, DateTime.monday, forceNext: false);
      _commit(ctx, s, raw, date);
      return;
    }

    final endWeek = RegExp(
      _wb(r'(نهايه\s+الاسبوع|نهاية\s+الاسبوع|اخر\s+الاسبوع|آخر\s+الاسبوع)'),
    ).firstMatch(s);
    if (endWeek != null) {
      final raw = endWeek.group(0)!;
      final date = _nextOrSameWeekday(today, DateTime.sunday, forceNext: false);
      _commit(ctx, s, raw, date);
      return;
    }

    // ============================================================
    // (3) بداية / نهاية الشهر
    // ============================================================

    final startMonth = RegExp(
      _wb(r'(بدايه\s+الشهر|بداية\s+الشهر|اول\s+الشهر)'),
    ).firstMatch(s);
    if (startMonth != null) {
      final raw = startMonth.group(0)!;
      final date = DateTime(today.year, today.month, 1);
      _commit(ctx, s, raw, date);
      return;
    }

    final endMonth = RegExp(
      _wb(r'(نهايه\s+الشهر|نهاية\s+الشهر|اخر\s+الشهر|آخر\s+الشهر)'),
    ).firstMatch(s);
    if (endMonth != null) {
      final raw = endMonth.group(0)!;
      final firstNextMonth = today.month == 12
          ? DateTime(today.year + 1, 1, 1)
          : DateTime(today.year, today.month + 1, 1);
      final date = firstNextMonth.subtract(const Duration(days: 1));
      _commit(ctx, s, raw, date);
      return;
    }

    // ============================================================
    // (4) تاريخ رقمي: 12/3 أو 12-3-2026
    // ============================================================

    final numericDate = RegExp(
      _wb(r'(\d{1,2})[\/\-\.](\d{1,2})(?:[\/\-\.](\d{2,4}))?'),
    ).firstMatch(s);

    if (numericDate != null) {
      final raw = numericDate.group(0)!;
      final d = int.parse(numericDate.group(1)!);
      final m = int.parse(numericDate.group(2)!);
      final yRaw = numericDate.group(3);

      final year = yRaw == null
          ? today.year
          : (yRaw.length == 2 ? 2000 + int.parse(yRaw) : int.parse(yRaw));

      final parsed = _safeDate(year, m, d);
      if (parsed != null) {
        final finalDate = (yRaw == null && parsed.isBefore(today))
            ? _safeDate(today.year + 1, m, d) ?? parsed
            : parsed;

        _commit(ctx, s, raw, finalDate);
        return;
      }
    }

    // ============================================================
    // (5) يوم + شهر عربي
    // ============================================================

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
      _wb(
        r'(\d{1,2})\s+(يناير|فبراير|مارس|ابريل|أبريل|مايو|يونيو|يوليو|اغسطس|أغسطس|سبتمبر|اكتوبر|أكتوبر|نوفمبر|ديسمبر)(?:\s+(\d{4}))?',
      ),
    ).firstMatch(s);

    if (arabicMonthDate != null) {
      final raw = arabicMonthDate.group(0)!;
      final day = int.parse(arabicMonthDate.group(1)!);
      final month = monthMap[arabicMonthDate.group(2)!]!;
      final yearStr = arabicMonthDate.group(3);

      final year = yearStr == null ? today.year : int.parse(yearStr);
      final parsed = _safeDate(year, month, day);

      if (parsed != null) {
        final finalDate = (yearStr == null && parsed.isBefore(today))
            ? _safeDate(today.year + 1, month, day) ?? parsed
            : parsed;

        _commit(ctx, s, raw, finalDate);
        return;
      }
    }

    // ============================================================
    // (6) يوم الأسبوع (الجمعة / الجمعة الجاية)
    // ============================================================

    final weekdayMatch = RegExp(
      _wb(
        r'(يوم\s+)?(السبت|الاحد|الاثنين|الاتنين|الثلاثاء|الاربعاء|الخميس|الجمعه)(\s+(الجاي|القادم|اللي\s+جاي))?',
      ),
    ).firstMatch(s);

    if (weekdayMatch != null) {
      final raw = weekdayMatch.group(0)!;
      final dayWord = weekdayMatch.group(2)!;
      final hasNext = weekdayMatch.group(3) != null;

      final target = _arabicWeekdayToDartWeekday(dayWord);
      if (target != null) {
        final date = _nextOrSameWeekday(today, target, forceNext: hasNext);
        _commit(ctx, s, raw, date);
        return;
      }
    }

    ctx.text = _clean(s);
  }

  // ============================================================
  // Helpers
  // ============================================================

  void _commit(
    final ParseContext ctx,
    final String s,
    final String raw,
    final DateTime date,
  ) {
    ctx.date = DateTime(date.year, date.month, date.day);
    ctx.tokens.add(Token(ExtractKind.date, raw));
    ctx.text = _clean(s.replaceAll(raw, ' '));
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
    _commit(ctx, s, raw, date);
    return true;
  }

  int? _arabicWeekdayToDartWeekday(final String d) {
    switch (d) {
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
    final DateTime from,
    final int targetWeekday, {
    required final bool forceNext,
  }) {
    final current = from.weekday;
    var delta = (targetWeekday - current) % 7;
    if (delta == 0 && forceNext) delta = 7;
    return from.add(Duration(days: delta));
  }

  DateTime? _safeDate(final int y, final int m, final int d) {
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    try {
      final dt = DateTime(y, m, d);
      if (dt.year != y || dt.month != m || dt.day != d) return null;
      return DateTime(dt.year, dt.month, dt.day);
    } catch (_) {
      return null;
    }
  }

  String _clean(final String s) => s.replaceAll(_spaces, ' ').trim();
}

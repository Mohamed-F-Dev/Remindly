import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class RelativeTimeExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;

    // نص ساعة
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(نص\s*ساعه|نص\s*ساعة))'),
      const Duration(minutes: 30),
    ))
      return;

    // ربع ساعة
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(ربع\s*ساعه|ربع\s*ساعة))'),
      const Duration(minutes: 15),
    ))
      return;

    // تلت / ثلث ساعة
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(تلت\s*ساعه|تلت\s*ساعة|ثلث\s*ساعه|ثلث\s*ساعة))'),
      const Duration(minutes: 20),
    ))
      return;

    // ساعة واحدة
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+ساعه|بعد\s+ساعة)'),
      const Duration(hours: 1),
    ))
      return;

    // ساعتين
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(ساعتين|ساعتان))'),
      const Duration(hours: 2),
    ))
      return;

    // عدد دقائق
    final minutesRegex = RegExp(r'بعد\s+(\d+)\s+(دقيقه|دقيقة|دقايق|دقائق|د)');
    final minutesMatch = minutesRegex.firstMatch(s);
    if (minutesMatch != null) {
      final mins = int.tryParse(minutesMatch.group(1)!) ?? 0;
      if (mins > 0) {
        ctx.relative = Duration(minutes: mins);
        ctx.tokens.add(Token(ExtractKind.relative, minutesMatch.group(0)!));
        s = s.replaceAll(minutesRegex, ' ');
        ctx.text = _cleanSpaces(s);
        return;
      }
    }

    // عدد ساعات
    final hoursRegex = RegExp(r'بعد\s+(\d+)\s+(ساعه|ساعة|ساعات|س)');
    final hoursMatch = hoursRegex.firstMatch(s);
    if (hoursMatch != null) {
      final hrs = int.tryParse(hoursMatch.group(1)!) ?? 0;
      if (hrs > 0) {
        ctx.relative = Duration(hours: hrs);
        ctx.tokens.add(Token(ExtractKind.relative, hoursMatch.group(0)!));
        s = s.replaceAll(hoursRegex, ' ');
        ctx.text = _cleanSpaces(s);
        return;
      }
    }

    // يوم / يومين / عدد أيام
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'بعد\s+يوم\b'),
      const Duration(days: 1),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'بعد\s+(يومين|يومان)\b'),
      const Duration(days: 2),
    ))
      return;

    final daysRegex = RegExp(r'بعد\s+(\d+)\s+(ايام|أيام|يوم)');
    final daysMatch = daysRegex.firstMatch(s);
    if (daysMatch != null) {
      final d = int.tryParse(daysMatch.group(1)!) ?? 0;
      if (d > 0) {
        ctx.relative = Duration(days: d);
        ctx.tokens.add(Token(ExtractKind.relative, daysMatch.group(0)!));
        s = s.replaceAll(daysRegex, ' ');
        ctx.text = _cleanSpaces(s);
        return;
      }
    }

    // أسابيع
    final weeksRegex = RegExp(r'بعد\s+(\d+)\s+(اسبوع|أسبوع|اسابيع|أسابيع)');
    final weeksMatch = weeksRegex.firstMatch(s);
    if (weeksMatch != null) {
      final w = int.tryParse(weeksMatch.group(1)!) ?? 0;
      if (w > 0) {
        ctx.relative = Duration(days: w * 7);
        ctx.tokens.add(Token(ExtractKind.relative, weeksMatch.group(0)!));
        s = s.replaceAll(weeksRegex, ' ');
        ctx.text = _cleanSpaces(s);
        return;
      }
    }

    // شهور (تقريبًا)
    final monthsRegex = RegExp(r'بعد\s+(\d+)\s+(شهر|شهور|أشهر)');
    final monthsMatch = monthsRegex.firstMatch(s);
    if (monthsMatch != null) {
      final m = int.tryParse(monthsMatch.group(1)!) ?? 0;
      if (m > 0) {
        ctx.relative = Duration(days: m * 30); // تقريبًا
        ctx.tokens.add(Token(ExtractKind.relative, monthsMatch.group(0)!));
        s = s.replaceAll(monthsRegex, ' ');
        ctx.text = _cleanSpaces(s);
        return;
      }
    }

    // سنوات (تقريبًا)
    final yearsRegex = RegExp(r'بعد\s+(\d+)\s+(سنة|سنين|سنوات)');
    final yearsMatch = yearsRegex.firstMatch(s);
    if (yearsMatch != null) {
      final y = int.tryParse(yearsMatch.group(1)!) ?? 0;
      if (y > 0) {
        ctx.relative = Duration(days: y * 365); // تقريبًا
        ctx.tokens.add(Token(ExtractKind.relative, yearsMatch.group(0)!));
        s = s.replaceAll(yearsRegex, ' ');
        ctx.text = _cleanSpaces(s);
        return;
      }
    }

    ctx.text = _cleanSpaces(s);
  }

  bool _matchAndReplace(
    final ParseContext ctx,
    final String s,
    final RegExp regex,
    final Duration duration,
  ) {
    final match = regex.firstMatch(s);
    if (match != null) {
      ctx.relative = duration;
      ctx.tokens.add(Token(ExtractKind.relative, match.group(0)!));
      ctx.text = _cleanSpaces(s.replaceAll(regex, ' '));
      return true;
    }
    return false;
  }

  String _cleanSpaces(final String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

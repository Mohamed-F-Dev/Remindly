import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class RelativeTimeExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;

    // (A) حالات خاصة قصيرة (لازم "بعد" عشان تبقى واضحة)
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(شويه|شوية|قليل))'),
      const Duration(minutes: 5),
    ))
      return;

    // (B1) ثابتة "بعد ..." (آمنة)
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(نص\s*ساعه|نص\s*ساعة))'),
      const Duration(minutes: 30),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(ربع\s*ساعه|ربع\s*ساعة))'),
      const Duration(minutes: 15),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(تلت\s*ساعه|تلت\s*ساعة|ثلث\s*ساعه|ثلث\s*ساعة))'),
      const Duration(minutes: 20),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(ساعه|ساعة))'),
      const Duration(hours: 1),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(ساعتين|ساعتان))'),
      const Duration(hours: 2),
    ))
      return;

    // (B2) ثابتة بدون "بعد" لكن لازم trigger بعدها (عشان "الساعة 5" ما تتكسرش)
    if (_matchFixedBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(نص\s*ساعه|نص\s*ساعة)\b'),
      const Duration(minutes: 30),
    ))
      return;
    if (_matchFixedBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(ربع\s*ساعه|ربع\s*ساعة)\b'),
      const Duration(minutes: 15),
    ))
      return;
    if (_matchFixedBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(تلت\s*ساعه|تلت\s*ساعة|ثلث\s*ساعه|ثلث\s*ساعة)\b'),
      const Duration(minutes: 20),
    ))
      return;
    if (_matchFixedBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(ساعتين|ساعتان)\b'),
      const Duration(hours: 2),
    ))
      return;
    if (_matchFixedBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(ساعه|ساعة)\b'),
      const Duration(hours: 1),
    ))
      return;

    // (C1) أرقام + وحدات مع "بعد" (آمنة)
    if (_matchNumberDuration(
      ctx,
      s,
      RegExp(r'بعد\s+(\d+)\s+(دقيقه|دقيقة|دقايق|دقائق|د)'),
      (final n) => Duration(minutes: n),
    ))
      return;
    if (_matchNumberDuration(
      ctx,
      s,
      RegExp(r'بعد\s+(\d+)\s+(ساعه|ساعة|ساعات|س)'),
      (final n) => Duration(hours: n),
    ))
      return;
    if (_matchNumberDuration(
      ctx,
      s,
      RegExp(r'بعد\s+(\d+)\s+(يوم|ايام|أيام)'),
      (final n) => Duration(days: n),
    ))
      return;
    if (_matchNumberDuration(
      ctx,
      s,
      RegExp(r'بعد\s+(\d+)\s+(اسبوع|أسبوع|اسابيع|أسابيع)'),
      (final n) => Duration(days: n * 7),
    ))
      return;
    if (_matchNumberDuration(
      ctx,
      s,
      RegExp(r'بعد\s+(\d+)\s+(شهر|شهور|أشهر)'),
      (final n) => Duration(days: n * 30),
    ))
      return;
    if (_matchNumberDuration(
      ctx,
      s,
      RegExp(r'بعد\s+(\d+)\s+(سنه|سنة|سنين|سنوات)'),
      (final n) => Duration(days: n * 365),
    ))
      return;

    // (C2) أرقام + وحدات بدون "بعد" لكن لازم trigger بعدها
    if (_matchNumberBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(\d+)\s+(دقيقه|دقيقة|دقايق|دقائق|د)\b'),
      (final n) => Duration(minutes: n),
    ))
      return;
    if (_matchNumberBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(\d+)\s+(ساعه|ساعة|ساعات|س)\b'),
      (final n) => Duration(hours: n),
    ))
      return;
    if (_matchNumberBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(\d+)\s+(يوم|ايام|أيام)\b'),
      (final n) => Duration(days: n),
    ))
      return;
    if (_matchNumberBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(\d+)\s+(اسبوع|أسبوع|اسابيع|أسابيع)\b'),
      (final n) => Duration(days: n * 7),
    ))
      return;
    if (_matchNumberBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(\d+)\s+(شهر|شهور|أشهر)\b'),
      (final n) => Duration(days: n * 30),
    ))
      return;
    if (_matchNumberBeforeTrigger(
      ctx,
      s,
      RegExp(r'\b(\d+)\s+(سنه|سنة|سنين|سنوات)\b'),
      (final n) => Duration(days: n * 365),
    ))
      return;

    // (D) مثنى وجمع خاص (مع "بعد" فقط لتقليل الغلط)
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(يومين|يومان))'),
      const Duration(days: 2),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+(اسبوعين|أسبوعين))'),
      const Duration(days: 14),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+شهرين)'),
      const Duration(days: 60),
    ))
      return;
    if (_matchAndReplace(
      ctx,
      s,
      RegExp(r'(بعد\s+سنتين)'),
      const Duration(days: 730),
    ))
      return;

    ctx.text = _cleanSpaces(s);
  }

  // تطابق وتستبدل (عام)
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

  // ثابت بدون "بعد" بشرط Trigger بعده
  bool _matchFixedBeforeTrigger(
    final ParseContext ctx,
    final String s,
    final RegExp regex,
    final Duration duration,
  ) {
    final match = regex.firstMatch(s);
    if (match == null) return false;

    final after = s.substring(match.end);
    if (!_hasTriggerSoon(after)) return false;

    ctx.relative = duration;
    ctx.tokens.add(Token(ExtractKind.relative, match.group(0)!));
    ctx.text = _cleanSpaces(s.replaceRange(match.start, match.end, ' '));
    return true;
  }

  // أرقام + وحدات (مع "بعد") عام
  bool _matchNumberDuration(
    final ParseContext ctx,
    final String s,
    final RegExp regex,
    final Duration Function(int) calc,
  ) {
    final match = regex.firstMatch(s);
    if (match != null) {
      final num = int.tryParse(match.group(1)!) ?? 0;
      if (num > 0) {
        ctx.relative = calc(num);
        ctx.tokens.add(Token(ExtractKind.relative, match.group(0)!));
        ctx.text = _cleanSpaces(s.replaceAll(regex, ' '));
        return true;
      }
    }
    return false;
  }

  // أرقام + وحدات بدون "بعد" بشرط Trigger بعده
  bool _matchNumberBeforeTrigger(
    final ParseContext ctx,
    final String s,
    final RegExp regex,
    final Duration Function(int) calc,
  ) {
    final match = regex.firstMatch(s);
    if (match == null) return false;

    final num = int.tryParse(match.group(1)!) ?? 0;
    if (num <= 0) return false;

    final after = s.substring(match.end);
    if (!_hasTriggerSoon(after)) return false;

    ctx.relative = calc(num);
    ctx.tokens.add(Token(ExtractKind.relative, match.group(0)!));
    ctx.text = _cleanSpaces(s.replaceRange(match.start, match.end, ' '));
    return true;
  }

  bool _hasTriggerSoon(final String textAfter) {
    // trigger لازم يبقى قريب: "و فكرني" / "فكرني" / "ذكرني" / "نبهني"
    return RegExp(
      r'^\s*(و)?\s*(فكرني|ذكرني|ذكّرني|نبهني|نبّهني)\b',
    ).hasMatch(textAfter);
  }

  String _cleanSpaces(final String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

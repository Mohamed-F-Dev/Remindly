import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';

DateTime? resolveDateTime(final ParseContext ctx) {
  // (1) Relative wins
  if (ctx.relative != null) {
    return ctx.now.add(ctx.relative!);
  }

  // (2) لو مفيش وقت: نسيبه null (UI تسأل)
  if (ctx.time == null) return null;

  // (3) التاريخ الافتراضي = النهارده لو المستخدم ما قالش تاريخ
  final baseDate =
      ctx.date ?? DateTime(ctx.now.year, ctx.now.month, ctx.now.day);

  var dt = DateTime(
    baseDate.year,
    baseDate.month,
    baseDate.day,
    ctx.time!.h,
    ctx.time!.m,
  );

  // (4) لو المستخدم ما قالش تاريخ صريح، والوقت خلص/عدّى => نخليه بكرة
  final hadExplicitDate = ctx.tokens.any((t) => t.kind == ExtractKind.date);
  if (!hadExplicitDate && dt.isBefore(ctx.now)) {
    dt = dt.add(const Duration(days: 1));
  }

  return dt;
}

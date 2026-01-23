import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class RepeatExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text;

    // يومي
    final dailyRegex = RegExp(
      r'(كل يوم|يوميًا?|يوميا|يومي|يومًا بعد يوم|يوم وراء يوم|يومًا بيوم|صباح كل يوم|مساء كل يوم|كل صباح|كل مساء|كل ليلة|بشكل يومي|بصورة يومية|على مدار اليوم|على مدار الساعة)',
    );

    // أسبوعي
    final weeklyRegex = RegExp(
      r'(كل أسبوع|كل اسبوع|أسبوعيًا?|اسبوعيًا?|أسبوعي|اسبوعي|أسبوع بعد أسبوع|اسبوع وراء اسبوع|بشكل أسبوعي|بصورة أسبوعية)',
    );

    // شهري
    final monthlyRegex = RegExp(
      r'(كل شهر|شهريًا?|شهريا|شهري|شهر بعد شهر|بشكل شهري|بصورة شهرية)',
    );

    if (dailyRegex.hasMatch(s)) {
      ctx.repeat = 'daily';
      ctx.tokens.add(Token(ExtractKind.repeat, 'daily'));
      s = s.replaceAll(dailyRegex, ' ');
    } else if (weeklyRegex.hasMatch(s)) {
      ctx.repeat = 'weekly';
      ctx.tokens.add(Token(ExtractKind.repeat, 'weekly'));
      s = s.replaceAll(weeklyRegex, ' ');
    } else if (monthlyRegex.hasMatch(s)) {
      ctx.repeat = 'monthly';
      ctx.tokens.add(Token(ExtractKind.repeat, 'monthly'));
      s = s.replaceAll(monthlyRegex, ' ');
    }

    ctx.text = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

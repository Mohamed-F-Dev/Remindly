import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/parser/extractors/extract_date.dart';
import 'package:remindly/domain/parser/extractors/extract_task.dart';
import 'package:remindly/domain/parser/extractors/extract_time.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';
import 'package:remindly/domain/parser/extractors/preprocess_extractor.dart';
import 'package:remindly/domain/parser/extractors/relative_time_extractors.dart';
import 'package:remindly/domain/parser/extractors/repeted_extractors.dart';
import 'package:remindly/domain/parser/resolver.dart';

class ReminderParser {
  ReminderParser();

  // مهم: RelativeTimeExtractor قبل Preprocess
  // عشان relative (بدون "بعد") ممكن يعتمد على وجود trigger قبل ما يتشال
  final List<Extractors> _pipeline = [
    RelativeTimeExtractor(),
    PreprocessExtractor(),
    RepeatExtractor(),
    DateExtractor(),
    TimeExtractor(),
    TaskExtractor(),
  ];

  ParsedReminder parse(final String input, {final DateTime? now}) {
    final ctx = ParseContext(now: now ?? DateTime.now(), text: input);

    for (final step in _pipeline) {
      step.apply(ctx);

      // Early exit لو relative موجود (اختياري لكن عملي)
      if (ctx.relative != null) break;
    }

    final dt = resolveDateTime(ctx);
    final task = ctx.task;

    // Validation بسيطة (بدون UI هنا)
    // - لو مفيش task => placeholder
    if (task == null || task.trim().isEmpty) {
      return ParsedReminder(
        task: 'Reminder',
        dateTime: dt ?? ctx.now.add(const Duration(minutes: 5)),
        isRelative: ctx.relative != null,
        repeat: ctx.repeat,
        tokens: List.unmodifiable(ctx.tokens),
      );
    }

    // - لو مفيش وقت نهائي => fallback مؤقت (الـ UI المفروض تسأل)
    if (dt == null) {
      final fallback = DateTime(ctx.now.year, ctx.now.month, ctx.now.day, 9, 0);
      return ParsedReminder(
        task: task,
        dateTime: fallback,
        isRelative: false,
        repeat: ctx.repeat,
        tokens: List.unmodifiable(ctx.tokens),
      );
    }

    return ParsedReminder(
      task: task,
      dateTime: dt,
      isRelative: ctx.relative != null,
      repeat: ctx.repeat,
      tokens: List.unmodifiable(ctx.tokens),
    );
  }
}

import 'package:remindly/domain/lexicon/reminder_lexicon.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

class TaskExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    var s = ctx.text.trim();
    if (s.isEmpty) {
      ctx.task = null;
      return;
    }

    // حاول تفصل المهمة باستخدام taskStarters
    final extracted = _extractAfterStarter(s);
    if (extracted != null && extracted.isNotEmpty) {
      ctx.task = extracted;
      return;
    }

    // fallback: اللي فاضل كله task
    ctx.task = s.isEmpty ? null : s;
  }

  String? _extractAfterStarter(final String text) {
    for (final starter in ReminderLexicon.taskStarters) {
      final m = RegExp(
        r'\b' + RegExp.escape(starter) + r'\b\s+(.+)$',
      ).firstMatch(text);
      if (m == null) continue;

      final candidate = m.group(1)!.trim();

      // لو اللي بعد starter شكل وقت/تاريخ -> تجاهل (خصوصًا "على/ل")
      if (_looksLikeTimeOrDate(candidate)) continue;

      return candidate;
    }
    return null;
  }

  bool _looksLikeTimeOrDate(final String text) {
    // وقت: "الساعة 5" / "5:30" / "صباح" / "مساء"
    if (RegExp(r'\b(الساعة|الساعه)\b').hasMatch(text)) return true;
    if (RegExp(r'\b\d{1,2}:\d{2}\b').hasMatch(text)) return true;
    if (RegExp(
      r'\b(صباح|مساء|ليل|بالليل|فجر|ظهر|الظهر|عصر|مغرب|عشاء|بعد\s+الظهر)\b',
    ).hasMatch(text)) {
      return true;
    }

    // تاريخ: "بكره/بعد بكره/النهارده/اليوم/امبارح" + أيام الأسبوع + تاريخ رقمي
    if (RegExp(
      r'\b(بكره|بعد\s+بكره|النهارده|اليوم|نهارده|امبارح)\b',
    ).hasMatch(text))
      return true;
    if (RegExp(
      r'\b(السبت|الاحد|الاثنين|الاتنين|الثلاثاء|الاربعاء|الخميس|الجمعه)\b',
    ).hasMatch(text))
      return true;
    if (RegExp(r'\b\d{1,2}[\/\-\.]\d{1,2}([\/\-\.]\d{2,4})?\b').hasMatch(text))
      return true;

    // relative: "بعد 10 دقايق" (لو لسه فاضلة لأي سبب)
    if (RegExp(
      r'\bبعد\s+\d+\s+(دقيقه|دقيقة|ساعه|ساعة|يوم|ايام|أيام|اسبوع|أسبوع|شهر|سنه|سنة)\b',
    ).hasMatch(text)) {
      return true;
    }

    return false;
  }
}

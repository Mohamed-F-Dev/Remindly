import 'package:remindly/core/utils/text_normalized.dart';
import 'package:remindly/domain/lexicon/reminder_lexicon.dart';
import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/parse_context.dart';
import 'package:remindly/domain/model/token.dart';
import 'package:remindly/domain/parser/extractors/extractors.dart';

//PreprocessExtractor
//extract tragers and fillters and clean the text
class PreprocessExtractor implements Extractors {
  @override
  void apply(final ParseContext ctx) {
    String s = TextNormalizer.normalize(ctx.text);

    //remove trigers
    for (var trager in ReminderLexicon.triggers) {
      if (_containsWholeWord(s, trager)) {
        s = removeWholeArabicWord(s, trager);
        ctx.tokens.add(Token(ExtractKind.trigger, trager));
      }

      // remove fillters
      for (final filler in ReminderLexicon.fillers) {
        if (_containsWholeWord(s, filler)) {
          s = removeWholeArabicWord(s, filler);
          ctx.tokens.add(Token(ExtractKind.filler, filler));
        }
      }

      ctx.text = s;
    }
  }

  // check text contains word
  bool _containsWholeWord(String text, String word) {
    if (word.isEmpty) return false;

    final tashkeel = RegExp(r'[\u064B-\u065F]');
    text = text.replaceAll(tashkeel, '');
    word = word.replaceAll(tashkeel, '');

    text = text.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');

    final words = text.split(RegExp(r'\s+'));

    for (final w in words) {
      if (w == word) return true;
    }
    return false;
  }

  //remove whole word funcation
  String removeWholeArabicWord(final String text, final String word) {
    if (word.isEmpty) return text;

    final tashkeel = RegExp(r'[\u064B-\u065F]');

    final normalizedWord = word.replaceAll(tashkeel, '');

    // تنظيف النص
    final cleanedText = text
        .replaceAll(tashkeel, '')
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');

    final words = cleanedText.split(RegExp(r'\s+'));

    final buffer = StringBuffer();
    for (final w in words) {
      if (w != normalizedWord) {
        buffer.write(w);
        buffer.write(' ');
      }
    }

    return buffer.toString().trim();
  }
}

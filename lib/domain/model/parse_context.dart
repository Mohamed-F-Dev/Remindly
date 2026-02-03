import 'package:remindly/domain/model/token.dart';

class ParseContext {
  final DateTime now;
  String text;
  final List<Token> tokens;

  DateTime? date;
  ({int h, int m})? time;
  Duration? relative;
  String? repeat;
  String? task;

  ParseContext({required this.now, required this.text, this.date})
    : tokens = [];
}

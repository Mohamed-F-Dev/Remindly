import 'package:remindly/domain/model/token.dart';

class ParsedReminder {
  final String task;
  final DateTime dateTime;
  final bool isRelative;
  final String? repeat;
  final List<Token> tokens;

  const ParsedReminder({
    required this.task,
    required this.dateTime,
    this.isRelative = false,
    this.repeat,
    this.tokens = const [],
  });
}

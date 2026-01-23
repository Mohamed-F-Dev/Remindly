import 'package:remindly/domain/model/extract_kind.dart';

class Token {
  final ExtractKind kind;
  final String raw;

  Token(this.kind, this.raw);
}

import 'package:remindly/domain/model/parse_context.dart';

abstract class Extractors {
  void apply(final ParseContext ctx);
}

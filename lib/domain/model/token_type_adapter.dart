import 'package:hive/hive.dart';
import 'package:remindly/domain/model/extract_kind.dart';
import 'package:remindly/domain/model/token.dart';

class TokenAdapter extends TypeAdapter<Token> {
  @override
  final int typeId = 2;

  @override
  Token read(BinaryReader reader) {
    final kindIndex = reader.readInt();
    final raw = reader.readString();

    return Token(ExtractKind.values[kindIndex], raw);
  }

  @override
  void write(BinaryWriter writer, Token obj) {
    writer.writeInt(obj.kind.index);
    writer.writeString(obj.raw);
  }
}

import 'package:hive_flutter/adapters.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/model/token.dart';

class ParsedReminderTypeAdapter extends TypeAdapter<ParsedReminder> {
  @override
  read(BinaryReader reader) {
    return ParsedReminder(
      task: reader.readString(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isRelative: reader.readBool(),
      repeat: reader.readString(),
      tokens: reader.readList().cast<Token>(),
    );
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, obj) {
    writer.writeString(obj.task);
    writer.writeInt(
      obj.dateTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    );
    writer.writeBool(obj.isRelative);
    writer.writeString(obj.repeat ?? "");
    writer.writeList(obj.tokens);
  }
}

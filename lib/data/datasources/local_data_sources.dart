import 'package:hive_flutter/hive_flutter.dart';
import 'package:remindly/domain/model/parse_reminder.dart';

abstract class LocalDataSources {
  Future<void> saveReminderToLocal({required final ParsedReminder reminder});
  Future<List<ParsedReminder>> getRemindersFromLocal();
}

class LocalDataSourcesImpl implements LocalDataSources {
  final Box _box;
  final String key = "reminders";
  LocalDataSourcesImpl(this._box);
  @override
  Future<void> saveReminderToLocal({
    required final ParsedReminder reminder,
  }) async {
    await _box.put("reminser", key);
  }

  @override
  Future<List<ParsedReminder>> getRemindersFromLocal() async {
    final reminders = _box.get("reminders", defaultValue: []);
    if (reminders is List) {
      return reminders.cast<ParsedReminder>();
    }
    return <ParsedReminder>[];
  }
}

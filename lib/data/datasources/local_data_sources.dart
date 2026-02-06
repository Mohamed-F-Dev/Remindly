import 'package:hive_flutter/hive_flutter.dart';
import 'package:remindly/domain/model/parse_reminder.dart';

abstract class LocalDataSources {
  Future<void> saveReminderToLocal({required final ParsedReminder reminder});
  Future<List<ParsedReminder>> getRemindersFromLocal();
  Future<void> removeItem({required final int id});
}

class LocalDataSourcesImpl implements LocalDataSources {
  final Box _box;
  final String key = "reminders";
  LocalDataSourcesImpl(this._box);
  @override
  Future<void> saveReminderToLocal({
    required final ParsedReminder reminder,
  }) async {
    final reminders = _getReminders();

    reminders.add(reminder);
    await _box.put(key, reminders);
  }

  @override
  Future<List<ParsedReminder>> getRemindersFromLocal() async {
    return _getReminders();
  }

  @override
  Future<void> removeItem({required int id}) async {
    final reminders = _getReminders();
    reminders.removeWhere((reminder) => reminder.id == id);
    _box.put(key, reminders);
  }

  List<ParsedReminder> _getReminders() {
    return List.from(
      _box.get(key, defaultValue: <ParsedReminder>[]),
    ).cast<ParsedReminder>();
  }
}

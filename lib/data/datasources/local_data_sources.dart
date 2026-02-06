import 'dart:developer';

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
    final reminders = List.from(
      _box.get(key, defaultValue: <ParsedReminder>[]),
    ).cast<ParsedReminder>();

    reminders.add(reminder);
    await _box.put(key, reminders);
  }

  @override
  Future<List<ParsedReminder>> getRemindersFromLocal() async {
    final reminders = List.from(
      _box.get(key, defaultValue: <ParsedReminder>[]),
    ).cast<ParsedReminder>();

    return reminders;
  }
}

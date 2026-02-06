import 'dart:developer';

import 'package:remindly/data/datasources/local_data_sources.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/parser/reminder_parser.dart';
import 'package:remindly/domain/repo/reminder_repo.dart';

class ReminderRepositoriesImpl implements ReminderRepositories {
  final ReminderParser _parser;
  final LocalDataSources _localDataSources;
  ReminderRepositoriesImpl({
    required ReminderParser parser,
    required final LocalDataSources localDataSources,
  }) : _parser = parser,
       _localDataSources = localDataSources;

  @override
  Future<ParsedReminder> addREminder({
    required String input,
    DateTime? datetime,
  }) async {
    try {
      final ParsedReminder reminder = _parser.parse(input, now: datetime);
      if (reminder.dateTime != null) {
        log(reminder.toString());
        log("save");
        _localDataSources.saveReminderToLocal(reminder: reminder);
      }
      log("sssssssssssssss");
      return reminder;
    } catch (e) {
      throw Exception('Failed to add reminder: $e');
    }
  }

  @override
  Future<List<ParsedReminder>> getreminders() async {
    return await _localDataSources.getRemindersFromLocal();
  }
}

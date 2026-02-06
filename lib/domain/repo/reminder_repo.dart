import 'package:remindly/domain/model/parse_reminder.dart';

abstract class ReminderRepositories {
  //============================add reminder with record
  Future<ParsedReminder> addREminder({
    required final String input,
    final DateTime? datetime,
  });

  //=================================get all reminders form local
  Future<List<ParsedReminder>> getreminders();

  //==============================remmove
  Future<void> removeReminder(final int id);

  // save reminder with parsed renider model
  Future<void> saveReminder({required final ParsedReminder reminder});
}

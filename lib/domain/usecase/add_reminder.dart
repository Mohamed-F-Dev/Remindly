import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/parser/reminder_parser.dart';
import 'package:remindly/domain/repo/reminder_repo.dart';

class AddReminderUseCase {
  final ReminderRepositories repo;
  const AddReminderUseCase({required this.repo});

  Future<ParsedReminder> call({
    required final String input,
    final DateTime? datetime,
  }) async {
    return await repo.addREminder(input: input, datetime: datetime);
  }
}

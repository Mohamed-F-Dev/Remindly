import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/repo/reminder_repo.dart';

class SaveReminderUseCase {
  final ReminderRepositories repo;
  const SaveReminderUseCase(this.repo);

  Future<void> call({required final ParsedReminder reminder}) async {
    await repo.saveReminder(reminder: reminder);
  }
}

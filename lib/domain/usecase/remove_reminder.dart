import 'package:remindly/domain/repo/reminder_repo.dart';

class RemoveReminderUseCase {
  final ReminderRepositories repo;
  const RemoveReminderUseCase(this.repo);
  Future<void> call({required final int id}) async {
    await repo.removeReminder(id);
  }
}

import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/repo/reminder_repo.dart';

class GetRemindersUseCase {
  final ReminderRepositories repo;
  const GetRemindersUseCase(this.repo);

  Future<List<ParsedReminder>> call() async {
    return repo.getreminders();
  }
}

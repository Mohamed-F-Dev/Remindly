import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/usecase/get_reminders.dart';
import 'package:remindly/domain/usecase/remove_reminder.dart';
import 'package:remindly/domain/usecase/save_reminder.dart';
part 'local_reminder_state.dart';

class LocalReminderCubit extends Cubit<LocalReminderState> {
  final GetRemindersUseCase getRemindersUseCase;
  final RemoveReminderUseCase removeReminderUseCase;
  final SaveReminderUseCase saveReminderUseCase;
  LocalReminderCubit({
    required this.saveReminderUseCase,
    required this.removeReminderUseCase,
    required this.getRemindersUseCase,
  }) : super(LocalReminderinit());

  Future<void> getreminders() async {
    try {
      final reminders = await getRemindersUseCase.call();
      emit(LocalReminderfinsh(List.from(reminders)));
    } on Exception catch (e) {
      emit(LocalReminderfailer(e.toString()));
    }
  }

  Future<void> removeReminder({required final int id}) async {
    try {
      await removeReminderUseCase.call(id: id);
      getreminders();
    } on Exception catch (e) {
      emit(LocalReminderfailer(e.toString()));
    }
  }

  Future<void> saveReminder({required final ParsedReminder reminder}) async {
    try {
      await saveReminderUseCase.call(reminder: reminder);
      getreminders();
    } catch (e) {
      emit(LocalReminderfailer(e.toString()));
    }
  }
}

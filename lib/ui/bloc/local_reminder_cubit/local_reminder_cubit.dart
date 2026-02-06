import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/usecase/get_reminders.dart';
part 'local_reminder_state.dart';

class LocalReminderCubit extends Cubit<LocalReminderState> {
  final GetRemindersUseCase _getRemindersUseCase;
  LocalReminderCubit(this._getRemindersUseCase) : super(LocalReminderinit());

  Future<void> getreminders() async {
    try {
      final reminders = await _getRemindersUseCase.call();
      emit(LocalReminderfinsh(List.from(reminders)));
    } on Exception catch (e) {
      emit(LocalReminderfailer(e.toString()));
    }
  }
}

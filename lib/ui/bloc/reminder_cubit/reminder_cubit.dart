import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:remindly/domain/usecase/add_reminder.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final AddReminderUseCase _reminderUseCase;
  ReminderCubit(this._reminderUseCase) : super(ReminderInitial());

  Future<void> addReminder({
    required final String input,
    final DateTime? datetime,
  }) async {
    emit(Reminderloading());
    try {
      final reminder = await _reminderUseCase(input: input, datetime: datetime);
      if (reminder.dateTime == null) {
        emit(ReminderNotTime());
      } else {
        emit(Reminderfinish());
      }
    } catch (e) {
      emit(ReminderFailure());
    }
  }
}

part of 'local_reminder_cubit.dart';

sealed class LocalReminderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocalReminderinit extends LocalReminderState {}

class LocalReminderLoading extends LocalReminderState {}

class LocalReminderfinsh extends LocalReminderState {
  final List<ParsedReminder> reminders;
  LocalReminderfinsh(this.reminders);
  @override
  List<Object?> get props => [reminders];
}

class LocalReminderfailer extends LocalReminderState {
  final String message;
  LocalReminderfailer(this.message);
  @override
  List<Object?> get props => [message];
}

part of 'reminder_cubit.dart';

sealed class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object> get props => [];
}

final class ReminderInitial extends ReminderState {}

final class Reminderloading extends ReminderState {}

final class Reminderfinish extends ReminderState {}

final class ReminderNotTime extends ReminderState {
  final ParsedReminder reminder;

  const ReminderNotTime({required this.reminder});
}

final class ReminderFailure extends ReminderState {}

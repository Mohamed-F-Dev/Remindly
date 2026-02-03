import 'package:flutter/material.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/parser/reminder_parser.dart';

abstract class ReminderRepositories {
  Future<ParsedReminder> addREminder({
    required final String input,
    final DateTime? datetime,
  });
  Future<List<ParsedReminder>> getreminders();
}

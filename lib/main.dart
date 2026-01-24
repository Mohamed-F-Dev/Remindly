import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:remindly/app.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/parser/reminder_parser.dart';

void main() {
  ReminderParser reminder = .new();

  final ParsedReminder = reminder.parse("  عندي مشوار كمان ساعتين   ");
  final tas = ParsedReminder.task;

  runApp(const MyApp());
}

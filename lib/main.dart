import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:remindly/app.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/parser/reminder_parser.dart';

void main() {
  ReminderParser reminder = ReminderParser();
  final ParsedReminder = reminder.parse("  عندي مشوار كمان ساعتين   ");
  final tas = ParsedReminder.task;
  ParsedReminder.tokens.forEach((e) {
    log(e.raw);
    log(e.kind.toString());
  });
  log(tas);
  log(ParsedReminder.dateTime.toString());
  // runApp(const MyApp());
}

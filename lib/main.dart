import 'package:flutter/material.dart';
import 'package:remindly/app.dart';
import 'package:remindly/core/di/init.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:remindly/core/di/di.dart';

Future<void> init() async {
  //hive
  await Hive.initFlutter();
  await initDI();
}

import 'package:flutter/material.dart';
import 'package:remindly/core/theme/app_color.dart';

class AppTheme {
  AppTheme._();
  static final theme = ThemeData(
    primaryColor: AppColor.info,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColor.background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        iconSize: 25,
        iconColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: AppColor.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColor.border),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:remindly/core/theme/app_color.dart';

class AppTheme {
  AppTheme._();
  static final theme = ThemeData(
    primaryColor: AppColor.primary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColor.background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: AppColor.primaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColor.border),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:remindly/core/routing/app_routing.dart';
import 'package:remindly/core/theme/app_theme.dart';
import 'package:remindly/ui/screen/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: const MyHomePage(),
      onGenerateRoute: AppRouting.ongenerateRout,
    );
  }
}

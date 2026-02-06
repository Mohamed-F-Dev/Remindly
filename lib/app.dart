import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindly/core/di/di.dart';
import 'package:remindly/core/routing/app_routing.dart';
import 'package:remindly/core/theme/app_theme.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LocalReminderCubit>()..getreminders(),
      child: MaterialApp(
        locale: const Locale('ar', 'EG'),
        title: 'Reminder App',
        theme: AppTheme.theme,

        onGenerateRoute: AppRouting.ongenerateRout,
      ),
    );
  }
}

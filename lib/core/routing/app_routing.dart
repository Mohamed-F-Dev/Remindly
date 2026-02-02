import 'package:flutter/material.dart';
import 'package:remindly/core/di/di.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';
import 'package:remindly/ui/screen/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouting {
  static const String home = "/home";

  static Route ongenerateRout(final RouteSettings setting) {
    switch (setting.name) {
      case home:
        return MaterialPageRoute(
          builder: (final context) => BlocProvider(
            create: (context) => sl<ReminderCubit>(),
            child: const MyHomePage(),
          ),
        );
      default:
        return MaterialPageRoute(builder: (final context) => const Default());
    }
  }
}

class Default extends StatelessWidget {
  const Default({super.key});

  @override
  Widget build(final BuildContext context) {
    return const Center(child: Text('Page not found'));
  }
}

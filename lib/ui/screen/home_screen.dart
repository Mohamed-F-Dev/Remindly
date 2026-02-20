import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:remindly/core/constant/app_animation.dart';

import 'package:remindly/core/utils/show_datatime.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';
import 'package:remindly/ui/widget/add_reminder.dart';

import 'package:remindly/ui/widget/empty_screen.dart';
import 'package:remindly/ui/widget/reminder_list.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocListener<ReminderCubit, ReminderState>(
            listener: (context, state) async {
              if (state is Reminderfinish) {
                context.read<LocalReminderCubit>().getreminders();
              } else if (state is ReminderNotTime) {
                //  time not found
                //1 show timer piker
                final date = await pickDateTime(context);
                //2 check date from piker null stop fun
                if (date == null) return;

                // add time this reminder
                final reminder = ParsedReminder(
                  task: state.reminder.task,
                  dateTime: date,
                  isRelative: state.reminder.isRelative,
                  repeat: state.reminder.repeat,
                  id: state.reminder.id,
                  tokens: state.reminder.tokens,
                );

                //save reminder to local and update
                context.read<LocalReminderCubit>().saveReminder(
                  reminder: reminder,
                );
              }
            },
            child: Column(
              crossAxisAlignment: .start,
              children: [
                SizedBox(height: 20),
                //========================add reminder button
                _buildAddReminderButton(context),

                SizedBox(height: 30),
                //=========================show reminders
                Text(
                  "Reminders",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                BlocBuilder<LocalReminderCubit, LocalReminderState>(
                  builder: (context, state) {
                    if (state is LocalReminderfinsh) {
                      if (state.reminders.isEmpty) {
                        return Align(alignment: .center, child: EmptyScreen());
                      }

                      return ReminderList(reminders: state.reminders);

                      //   Column(
                      //   children: state.reminders
                      //       .map(
                      //         (reminder) => CardReminder(reminder: reminder),
                      //       )
                      //       .toList(),
                      // );
                    }

                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card _buildAddReminderButton(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,

          children: [
            Text(
              "add reminders",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton(
              onPressed: () async {
                //=========================== add reminder for record

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AddReminder(),
                ).then((value) {
                  if (value != null && value is String) {
                    if (value.isEmpty) {
                      if (!mounted) return;
                      context.read<ReminderCubit>().addReminder(
                        input: "بعد  ثانيه   سأكون في المنزل",
                      );
                    }
                  }
                });
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

// بعد دقيقه او دقيقاتان

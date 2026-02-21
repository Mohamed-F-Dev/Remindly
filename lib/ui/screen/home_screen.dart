import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindly/core/utils/show_datatime.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';
import 'package:remindly/ui/widget/button_add_reminder.dart';

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
      floatingActionButton: ButtonAddReminder(),

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
                Text(
                  "Welcome",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Speak your task instead of typing \n Ready to organize your day and add new tasks?",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Divider(),
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
}

// بعد دقيقه او دقيقاتان

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';
import 'package:remindly/ui/widget/add_reminder.dart';
import 'package:remindly/ui/widget/empty_screen.dart';

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
        child: SingleChildScrollView(
          child: BlocListener<ReminderCubit, ReminderState>(
            listener: (context, state) {
              if (state is Reminderfinish) {
                context.read<LocalReminderCubit>().getreminders();
              }
            },
            child: Column(
              children: [
                SizedBox(height: 20),
                //========================add reminder button
                _buildAddReminderButton(context),

                SizedBox(height: 30),
                //=========================show reminders
                BlocBuilder<LocalReminderCubit, LocalReminderState>(
                  builder: (context, state) {
                    if (state is LocalReminderfinsh) {
                      if (state.reminders.isEmpty) {
                        return EmptyScreen();
                      }

                      return Column(
                        children: [
                          CupertinoTimerPicker(
                            mode: CupertinoTimerPickerMode.hm, // ساعات + دقائق
                            initialTimerDuration: const Duration(minutes: 5),
                            onTimerDurationChanged: (Duration newDuration) {
                              setState(() {
                                // selectedDuration = newDuration;
                              });
                            },
                          ),
                          EmptyScreen(),
                        ],
                      );
                      // return Column(
                      //   children: state.reminders
                      //       .map(
                      //         (remindre) => Card(
                      //           child: ListTile(
                      //             title: Text(remindre.task),
                      //             subtitle: Text(remindre.dateTime.toString()),
                      //           ),
                      //         ),
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
                // showTimePicker(context: context, initialTime: TimeOfDay.now());
                // showDialog(
                //   barrierDismissible: false,
                //   context: context,
                //   builder: (context) => AddReminder(),
                // ).then((value) {
                //   if (value != null && value is String) {
                //     if (value.isEmpty) {
                //       if (!mounted) return;
                //       context.read<ReminderCubit>().addReminder(
                //         input: " عندي مذاكره  الساعه عشره ",
                //       );
                //     }
                //   }
                // });
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:remindly/core/constant/app_animation.dart';
import 'package:remindly/core/theme/app_color.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';
import 'package:remindly/ui/widget/card_reminder.dart';

class ReminderDetilsScreen extends StatelessWidget {
  final ParsedReminder reminder;
  const ReminderDetilsScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final datetime = reminder.dateTime ?? DateTime.now();
    int hour12 = datetime.hour % 12 == 0 ? 12 : datetime.hour % 12;
    String period = datetime.hour < 12 ? "AM" : "PM";
    final String date = "${datetime.year}/${datetime.month}/${datetime.day}";

    final String time = "$hour12:${datetime.minute} :$period";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reminder Detils",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Column(
          children: [
            Align(
              alignment: .center,
              child: Lottie.asset(AppAnimation.schedule, height: 200),
            ),
            SizedBox(height: 20),
            Card(
              color: CupertinoColors.darkBackgroundGray,
              child: ListTile(
                leading: Icon(Icons.task_outlined, color: AppColor.background),
                title: Text(
                  reminder.task,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                trailing: _buildContaineredit(
                  onPressed: () {},
                  color: Colors.white24,
                ),
              ),
            ),

            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.date_range),
                title: Text(
                  date,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                ),
                trailing: _buildContaineredit(onPressed: () {}),
              ),
            ),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.timelapse_rounded),
                title: Text(
                  time,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                ),

                trailing: _buildContaineredit(onPressed: () {}),
              ),
            ),
            SizedBox(height: 30),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => confirmDelete(
                        context,
                        onPressed: () {
                          context.read<LocalReminderCubit>().removeReminder(
                            id: reminder.id,
                          );
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ).then((value) {
                      if (value != null && value) {
                        Navigator.maybePop(context);
                      }
                    });
                  },
                  child: Text(
                    "Delete",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildContaineredit({
    required final VoidCallback onPressed,
    Color color = Colors.black54,
  }) {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.edit, color: Colors.amber[600], size: 18),
      ),
    );
  }
}

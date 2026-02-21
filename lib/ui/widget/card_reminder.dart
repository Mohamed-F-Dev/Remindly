import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:remindly/core/constant/app_animation.dart';
import 'package:remindly/core/theme/app_color.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/screen/reminder_detils_screen.dart';

class CardReminder extends StatelessWidget {
  final ParsedReminder reminder;
  const CardReminder({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final datetime = reminder.dateTime ?? DateTime.now();
    int hour12 = datetime.hour % 12 == 0 ? 12 : datetime.hour % 12;
    String period = datetime.hour < 12 ? "AM" : "PM";
    final String date = "${datetime.year}/${datetime.month}/${datetime.day}";

    final String time = "$hour12:${datetime.minute} :$period";
    return Card(
      color: Colors.white,

      shadowColor: AppColor.textPrimary,
      elevation: 2,
      surfaceTintColor: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReminderDetilsScreen(reminder: reminder),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(5),
          child: Stack(
            children: [
              ListTile(
                minLeadingWidth: 3,
                leading: Container(
                  height: 50,
                  width: 2,
                  decoration: BoxDecoration(color: AppColor.primary),
                ),
                title: Text(reminder.task),
                subtitle: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      date,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.copyWith(color: Colors.grey),
                    ),
                    Text(
                      time,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: EdgeInsets.only(
                    right: 5,
                    top: 5,
                    bottom: 2,
                    left: 2,
                  ),
                  alignment: .center,

                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 30,
                  width: 30,

                  child: Lottie.asset(AppAnimation.watch),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

CupertinoAlertDialog confirmDelete(
  BuildContext context, {
  void Function()? onPressed,
}) {
  return CupertinoAlertDialog(
    title: Text("Delete"),
    content: Text("Are you Shour Delete This Reminder "),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: Text("Cancel", style: Theme.of(context).textTheme.titleMedium!),
      ),
      TextButton(
        onPressed: onPressed,
        child: Text(
          "Delete",
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.red),
        ),
      ),
    ],
  );
}
       // trailing: Transform.translate(
            //   offset: Offset(0, -20),
            //   child: PopupMenuButton<String>(
            //     padding: EdgeInsets.all(0),
          
            //     color: Colors.white,
            //     onSelected: (value) {
            //       if (value == 'edit') {
            //       } else if (value == 'delete') {
            //         showDialog(
            //           context: context,
            //           builder: (context) => confirmDelete(context),
            //         );
            //       }
            //     },
            //     itemBuilder: (BuildContext context) => [
            //       const PopupMenuItem(value: 'edit', child: Text('Edit')),
            //       const PopupMenuItem(value: 'delete', child: Text('Delete')),
            //     ],
            //     child: Icon(Icons.more_vert),
            //   ),
            // ),
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindly/core/theme/app_color.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';

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
      child: ListTile(
        title: Text("Task : ${reminder.task}"),
        subtitle: Column(
          crossAxisAlignment: .start,
          children: [Text("Date   : $date"), Text("Time  : $time")],
        ),
        trailing: Transform.translate(
          offset: Offset(0, -20),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.all(0),

            color: Colors.white,
            onSelected: (value) {
              if (value == 'edit') {
              } else if (value == 'delete') {
                print("reminder deleted");
                context.read<LocalReminderCubit>().removeReminder(
                  id: reminder.id,
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            child: Icon(Icons.more_vert),
          ),
        ),
      ),
    );
  }
}

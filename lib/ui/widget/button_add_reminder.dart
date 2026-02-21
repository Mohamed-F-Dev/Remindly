import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindly/core/theme/app_color.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';
import 'package:remindly/ui/widget/speaker.dart';

class ButtonAddReminder extends StatelessWidget {
  const ButtonAddReminder({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: AppColor.primary,
      onPressed: () {
        //========================add reminder button
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AddReminder(),
        ).then((value) {
          if (value != null && value is String) {
            if (value.isEmpty) {
              // if (!mounted) return;
              context.read<ReminderCubit>().addReminder(
                input: "بعد  ثانيه   سأكون في المنزل",
              );
            }
          }
        });
      },
      label: ToggleButon(),
    );
  }
}

class ToggleButon extends StatefulWidget {
  const ToggleButon({super.key});

  @override
  State<ToggleButon> createState() => _ToggleButon();
}

class _ToggleButon extends State<ToggleButon> {
  ValueNotifier<bool> isaniamtion = ValueNotifier(false);
  Timer? timer;

  @override
  void initState() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 4), (_) {
      isaniamtion.value = !isaniamtion.value;
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: .center,

        children: [
          ValueListenableBuilder(
            valueListenable: isaniamtion,
            builder: (context, value, child) {
              return AnimatedSwitcher(
                switchInCurve: Curves.easeInOut,
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: value
                    ? Icon(Icons.mic, color: Colors.white, key: ValueKey('mic'))
                    : Icon(
                        Icons.add,
                        color: Colors.white,
                        key: ValueKey('add'),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

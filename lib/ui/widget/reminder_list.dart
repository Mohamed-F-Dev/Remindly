import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';
import 'package:remindly/ui/widget/card_reminder.dart';

class ReminderList extends StatefulWidget {
  final List<ParsedReminder> reminders;
  const ReminderList({super.key, required this.reminders});

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.reminders.length,
        itemBuilder: (context, index) {
          return AnimatedReminderItem(
            // key: ValueKey(widget.reminders[index].id),
            reminder: widget.reminders[index],
            index: index,
            // delay: index * 100, // delay لكل عنصر
          );
        },
      ),
    );
  }
}

class AnimatedReminderItem extends StatefulWidget {
  final ParsedReminder reminder;
  final int index; // استخدمنا index بدل delay
  const AnimatedReminderItem({
    super.key,
    required this.reminder,
    required this.index,
  });

  @override
  State<AnimatedReminderItem> createState() => _AnimatedReminderItemState();
}

class _AnimatedReminderItemState extends State<AnimatedReminderItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // مدة ثابتة
    );

    // Slide من اليمين لو index زوجي، ومن اليسار لو فردي
    _slideAnimation = Tween<Offset>(
      begin: widget.index % 2 == 0 ? const Offset(1, 0) : const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // ظهور العناصر واحد واحد بالتتابع
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: ValueKey(widget.reminder.id),

          direction: DismissDirection.startToEnd, // أو startToEnd أو horizontal
          onDismissed: (direction) {},
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder: (context) {
                return confirmDelete(
                  context,
                  onPressed: () {
                    context.read<LocalReminderCubit>().removeReminder(
                      id: widget.reminder.id,
                    );
                    Navigator.of(context).pop(true);
                  },
                );
              },
            );
          },
          background: Transform.scale(
            scaleY: 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                gradient: LinearGradient(colors: [Colors.pink, Colors.red]),
                borderRadius: BorderRadius.circular(12),
              ),

              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
          ),
          child: CardReminder(reminder: widget.reminder),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:remindly/core/theme/app_color.dart';

class CustomButtonAnimation extends StatefulWidget {
  final VoidCallback ontap;
  final bool isAnimating;

  const CustomButtonAnimation({
    super.key,
    required this.ontap,
    this.isAnimating = false,
  });

  @override
  State<CustomButtonAnimation> createState() => _CustomButtonAnimationState();
}

class _CustomButtonAnimationState extends State<CustomButtonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
      reverseDuration: Duration(milliseconds: 1500),
    );

    if (widget.isAnimating) {
      animationController.repeat(reverse: true);
    }
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final value = animationController.value;
        log(value.toString());
        return InkWell(
          onTap: () {
            widget.ontap();
          },
          child: Transform.scale(
            scale: 1 + (0.09 * value),

            child: Container(
              height: 65,
              width: 65,
              child: widget.isAnimating
                  ? Icon(Icons.mic, color: Colors.white, size: 28)
                  : Icon(Icons.mic_off, color: Colors.white, size: 28),
              decoration: BoxDecoration(
                color: AppColor.info,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurStyle: BlurStyle.solid,
                    color: AppColor.info.withOpacity(0.3 - value * 0.0),
                    spreadRadius: 8 * value,
                    blurRadius: 20 * value,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

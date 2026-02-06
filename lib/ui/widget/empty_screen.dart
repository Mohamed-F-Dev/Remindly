import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:remindly/core/constant/app_animation.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      children: [
        SizedBox(height: 80),
        Text("Not Data", style: Theme.of(context).textTheme.titleLarge),
        Lottie.asset(AppAnimation.notdata, height: 200),
      ],
    );
  }
}

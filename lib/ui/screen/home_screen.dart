
import 'package:flutter/material.dart';

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
        child: Column(
          children: [
            Text("فاكرني", style: Theme.of(context).textTheme.headlineSmall),
            // AvatarGlow(child:Icon(Icons.))
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:remindly/core/common/button_animation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final SpeechToText _speechToText = SpeechToText();
  bool __speechEnabled = false;
  Timer? _timeout;

  String _record = "";

  @override
  void initState() {
    super.initState();

    _initSpeech();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _speechToText.stop();
    super.dispose();
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        _record = result.recognizedWords;
        log(result.finalResult.toString());
        if (result.finalResult) {
          Navigator.maybePop(context, _record);
        }
      },

      localeId: "ar_EG",
      listenFor: Duration(seconds: 9),
    );
    _startTimer();
  }

  _startTimer() {
    _timeout?.cancel();
    _timeout = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_speechToText.isNotListening) {
        if (_record.isEmpty) {
          _timeout?.cancel();
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, _record);
          }
        }
      }
    });
  }

  //==============init speech
  Future<void> _initSpeech() async {
    __speechEnabled = await _speechToText.initialize();
    if (__speechEnabled) {
      final locales = await _speechToText.locales();

      locales.add(LocaleName('ar_EG', 'Arabic (Egypt)'));
      _startListening();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      child: Column(
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CustomButtonAnimation(ontap: () {}, isAnimating: true),
        ],
      ),
    );
  }
}

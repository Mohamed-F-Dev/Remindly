import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindly/core/common/button_animation.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';
import 'package:remindly/ui/widget/add_reminder.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool __speechEnabled = false;
  String _record = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  //==============init speech
  Future<void> _initSpeech() async {
    __speechEnabled = await _speechToText.initialize();
    if (__speechEnabled) {
      final locales = await _speechToText.locales();

      locales.add(LocaleName('ar_EG', 'Arabic (Egypt)'));
    }

    setState(() {});
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            Card(
              elevation: 1,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,

                  children: [
                    Text(
                      "add reminders",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AddReminder(),
                        ).then(
                          (value) => print("${value.toString()} sddddddddd"),
                        );
                      },
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            CustomButtonAnimation(
              ontap: () async {
                Future.delayed(Duration(seconds: 1));
                setState(() {});
                if (!__speechEnabled) {
                  return;
                }
                if (_speechToText.isListening) {
                  _speechToText.stop();

                  return;
                }
                _speechToText.listen(
                  onResult: (result) {
                    _record = result.recognizedWords;
                    setState(() {});
                  },
                  localeId: 'ar_EG', // Set the locale to Arabic (Egypt)
                );
              },

              isAnimating: _speechToText.isListening,
            ),
            BlocBuilder<ReminderCubit, ReminderState>(
              builder: (context, state) {
                if (state is Reminderloading) {
                  return CircularProgressIndicator();
                } else if (state is Reminderfinish) {
                  return Text('تم إضافة التذكير بنجاح');
                } else if (state is ReminderNotTime) {
                  return Text('تم إضافة التذكير بدون وقت محدد');
                } else if (state is ReminderFailure) {
                  return Text('فشل في إضافة التذكير');
                }

                return Container();
              },
            ),
            Text(_record),
          ],
        ),
      ),
    );
  }
}

class syHomePage extends StatefulWidget {
  const syHomePage({Key? key}) : super(key: key);

  @override
  State<syHomePage> createState() => _syHomePagestate();
}

class _syHomePagestate extends State<syHomePage> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _lastWords = '';

  String? _selectedLocaleId;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print("$status ddddddddddddddddddddd"),
    );

    if (_speechEnabled) {
      final locales = await _speechToText.locales();

      locales.add(LocaleName('ar_EG', 'Arabic (Egypt)'));
      final selectedLocale = locales.firstWhere(
        (l) => l.localeId.startsWith('ar'),
        orElse: () => locales.first,
      );
      for (var l in locales) {
        debugPrint('Locale: ${l.localeId} - ${l.name}');
      }
      _selectedLocaleId = selectedLocale.localeId;
    }

    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _selectedLocaleId, // 👈 هنا اللغة
    );

    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Recognized words:', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? _lastWords
                      : _speechEnabled
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isNotListening
            ? _startListening
            : _stopListening,
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

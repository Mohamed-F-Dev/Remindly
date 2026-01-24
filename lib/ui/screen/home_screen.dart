
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:remindly/core/theme/app_color.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
        child: syHomePage(),
//         child: Column(
//
//           children: [
//
//             Align(
//              alignment: Alignment.center,
//
//                 child: Text("فاكرني", style: Theme.of(context).textTheme.headlineSmall)),
//                    SizedBox( height: 30,) ,
//             AvatarGlow(
//
//                  animate: true,
//                 duration: Duration(seconds: 1),
//                 glowColor: AppColor.primaryLight,
// repeat: true,
// curve: Curves.easeInOut,
//                 startDelay: Duration(seconds: 1),
//
//
//                 child:Padding( padding: EdgeInsetsGeometry.all(20) , child: Icon(Icons.record_voice_over)))
//           ],
//         ),
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
    _speechEnabled = await _speechToText.initialize();

    if (_speechEnabled) {
      final locales = await _speechToText.locales();
      for (var l in locales) {
        debugPrint('Locale: ${l.localeId} - ${l.name}');
      }
      final selectedLocale = locales.firstWhere(
            (l) => l.localeId.startsWith('ar'),
        orElse: () => locales.first,
      );

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
        onPressed:
        _speechToText.isNotListening ? _startListening : _stopListening,
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
        ),
      ),
    );
  }
}
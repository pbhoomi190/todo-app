import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/constants/constants.dart';

typedef void SpeechPlayingCallback(bool isPlaying);
class TextToSpeech {

  final SpeechPlayingCallback isPlaying;
  TextToSpeech({this.isPlaying});

  static FlutterTts _flutterTts;

  dispose() {
    _flutterTts.stop();
  }

  initializeTts() {

    _flutterTts = FlutterTts();
    setTtsLanguage();

    _flutterTts.setStartHandler(() {
      debugPrint("start handler called");
      isPlaying(true);
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint("complete handler called");
      isPlaying(false);
    });

    _flutterTts.setErrorHandler((err) {
      debugPrint("error handler called");
      isPlaying(false);
    });
  }

  Future speak(String text) async {
    print("text to speak: $text");
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1)
        isPlaying(true);
    }
  }

  Future stop() async {
    print("stop called");
    var result = await _flutterTts.stop();
    if (result == 1)
      isPlaying(false);
  }

  void setTtsLanguage() async {
    var language = appGlobalLocale.languageCode;
    await _flutterTts.setLanguage(language);
  }
}
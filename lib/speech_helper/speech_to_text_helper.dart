import 'package:flutter/cupertino.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:rxdart/rxdart.dart';

class SpeechToConvertText {
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String currentLocaleId = "";

  List<LocaleName> localeNames = [];
  final permissionObserver = PublishSubject<bool>();
  final resultObserver = PublishSubject<String>();

  SpeechToText speech = SpeechToText();

  static SpeechToConvertText _speechToConvertText;
  static bool _hasSpeech;

  SpeechToConvertText._createInstance();

  factory SpeechToConvertText() {
    if (_speechToConvertText == null) {
      _speechToConvertText = SpeechToConvertText._createInstance();
    }
    return _speechToConvertText;
  }

  Future<bool> get speechToText async {
    if (_hasSpeech == null) {
      _hasSpeech = await initialize();
    }
    return _hasSpeech;
  }

  void startListening() {
    if (appGlobalLocale.languageCode == 'en') {
      switchLang('en_US');
    } else if (appGlobalLocale.languageCode == 'hi') {
      switchLang('hi_IN');
    } else if (appGlobalLocale.languageCode == 'gu') {
      switchLang("gu_IN");
    } else if (appGlobalLocale.languageCode == 'es') {
      switchLang("es_CL");
    } else if (appGlobalLocale.languageCode == 'fr') {
      switchLang("fr_FR");
    } else if (appGlobalLocale.languageCode == 'ar') {
      switchLang('ar_EG');
    }
    askPermission();
    listen();
  }

  void listen() async {
    bool hasSpeech = await this.speechToText;
    lastError = "";
    speech.listen(
        onResult: resultListener,
        localeId: currentLocaleId
    );
  }

  void stopListening() {
    speech.stop();
  }

  void cancelListening() {
    speech.cancel();
  }

  Future<void> askPermission() async {
    var res = await Permission.speech.isGranted;
    if (!res) {
      var result = await Permission.speech.request();
      if (result == PermissionStatus.granted) {
        permissionObserver.add(true);
      } else {
        permissionObserver.add(false);
      }
    } else {
      permissionObserver.add(true);
    }
  }

  Future<bool> initialize() async {

    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    debugPrint("Initialized");
    if (hasSpeech) {
      localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      currentLocaleId = systemLocale.localeId;
    }
    return hasSpeech;
  }

  void resultListener(SpeechRecognitionResult result) {
    debugPrint("result listner =====> ${result.recognizedWords}");
    resultObserver.add(lastWords + " " + result.recognizedWords);
  }

  void errorListener(SpeechRecognitionError error) {
     print("Received error status: $error, listening: ${speech.isListening}");
  }

  void statusListener(String status) {
      lastStatus = "$status";
  }

  switchLang(selectedVal) {
    currentLocaleId = selectedVal;
    print(selectedVal);
  }
}
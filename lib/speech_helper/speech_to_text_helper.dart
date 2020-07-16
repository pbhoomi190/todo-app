import 'package:flutter/cupertino.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:rxdart/rxdart.dart';

typedef void AvailableCallback(bool isAvailable);
typedef void ListeningCallback(bool isListening);
typedef void ResultTextCallback(String result);
typedef void PermissionCallback(bool isGranted);
/*class SpeechToText {

  SpeechRecognition _speechRecognition;
  bool isAvailable = false;
  bool isListening = false;
  String resultText = "";
  final AvailableCallback onAvailable;
  final ListeningCallback onListening;
  final ResultTextCallback onResult;
  final PermissionCallback onPermissionStatus;

  SpeechToText({this.onAvailable, this.onListening, this.onResult, this.onPermissionStatus});

  Future<void> askPermission() async {
    var res = await Permission.speech.isGranted;
    if (!res) {
      var result = await Permission.speech.request();
      if (result == PermissionStatus.granted) {
        onPermissionStatus(true);
        checkAvailability();
      } else {
        onPermissionStatus(false);
      }
    } else {
      onPermissionStatus(true);
      checkAvailability();
    }
  }

  checkAvailability() {
    _speechRecognition.setAvailabilityHandler(
            (bool result) {
          isAvailable = result;
          onAvailable(result);
        }
    );

    _speechRecognition.setRecognitionStartedHandler(
            () {
          isListening = true;
          onListening(true);
        }
    );

    _speechRecognition.setRecognitionResultHandler(
            (String speech) {
          resultText = speech;
          onResult(speech);
        }
    );

    _speechRecognition.setRecognitionCompleteHandler(
            () {
          isListening = false;
          onListening(false);
        }
    );

    _speechRecognition.activate().then(
            (result) {
          isAvailable = result;
          onAvailable(result);
        }
    );
  }

  void initSpeechRecognizer() async {
    _speechRecognition = SpeechRecognition();

    checkAvailability();
  }

  listen() {
    print("is available === $isAvailable is listening === $isListening");
    askPermission();
    if (isAvailable && !isListening)
      _speechRecognition
          .listen(locale: "en_US")
          .then((result) => print('$result'));
  }

  cancel() {
    if (isListening)
      _speechRecognition.cancel().then((value) {
        isListening = value;
        resultText = "";
        onListening(value);
        onResult("");
      });
  }

  stop() {
    if (isListening)
      _speechRecognition.stop().then((value) {
        isListening = value;
        onListening(value);
      });
  }
} */




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
    lastWords = "";
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
    lastWords = "${result.recognizedWords} - ${result.finalResult}";
    debugPrint("result listner =====> ${result.recognizedWords}");
    resultObserver.add(result.recognizedWords);
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
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

typedef void AvailableCallback(bool isAvailable);
typedef void ListeningCallback(bool isListening);
typedef void ResultTextCallback(String result);
typedef void PermissionCallback(bool isGranted);
class SpeechToText {

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
}
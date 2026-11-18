import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService();

  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _ready;

  Future<bool> init() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      return false;
    }
    _ready = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _ready;
  }

  Future<void> start({
    required void Function(String text) onResult,
    String localeId = 'zh_CN',
  }) async {
    if (!_ready) {
      final ok = await init();
      if (!ok) return;
    }
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: localeId,
      ),
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }
}

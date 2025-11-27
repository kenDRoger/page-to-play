
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool isPlaying = false;
  Completer<void> _speechCompleter = Completer();
  Function(String, int, int, String)? _progressHandler;

  TtsService() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      if (!_speechCompleter.isCompleted) {
        _speechCompleter.complete();
      }
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      _progressHandler?.call(text, start, end, word);
    });
  }

  void setProgressHandler(Function(String, int, int, String) handler) {
    _progressHandler = handler;
  }

  Future<void> speak(String text) async {
    isPlaying = true;
    _speechCompleter = Completer();
    await _flutterTts.speak(text);
    return _speechCompleter.future;
  }

  Future<void> pause() async {
    isPlaying = false;
    await _flutterTts.pause();
  }

  Future<void> stop() async {
    isPlaying = false;
    await _flutterTts.stop();
  }
}

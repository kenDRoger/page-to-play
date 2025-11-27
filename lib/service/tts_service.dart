
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class TtsPreferences {
  Map<String, String>? voice;
  String? voiceName;
  double speechRate = 0.5;
}

final TtsPreferences ttsPreferences = TtsPreferences();

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool isPlaying = false;
  Completer<void> _speechCompleter = Completer();
  Function(String, int, int, String)? _progressHandler;

  TtsService() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(ttsPreferences.speechRate);
    if (ttsPreferences.voice != null) {
      _flutterTts.setVoice(ttsPreferences.voice!);
    }

    _flutterTts.setCompletionHandler(() {
      if (!_speechCompleter.isCompleted) {
        _speechCompleter.complete();
      }
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      _progressHandler?.call(text, start, end, word);
    });
  }

  static Future<List<dynamic>> getVoices() async {
    return await FlutterTts().getVoices;
  }

  static Future<void> setVoice(Map<String, String> voice) async {
    await FlutterTts().setVoice(voice);
    ttsPreferences.voice = voice;
    ttsPreferences.voiceName = voice['name'];
  }

  static Future<void> setSpeechRate(double rate) async {
    await FlutterTts().setSpeechRate(rate);
    ttsPreferences.speechRate = rate;
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


import 'package:flutter/material.dart';
import 'package:page_to_play/service/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, String>> _voices = [];

  @override
  void initState() {
    super.initState();
    _getVoices();
  }

  Future<void> _getVoices() async {
    final voices = await TtsService.getVoices();
    _voices = voices.map((v) => Map<String, String>.from(v)).toList();
    setState(() {});
  }

  Future<void> _setVoice(String? voiceName) async {
    if (voiceName != null) {
      final selectedVoice = _voices.firstWhere((v) => v['name'] == voiceName);
      await TtsService.setVoice(selectedVoice);
      setState(() {});
    }
  }

  Future<void> _setSpeechRate(double rate) async {
    await TtsService.setSpeechRate(rate);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Default TTS Voice'),
            subtitle: DropdownButton<String>(
              value: ttsPreferences.voiceName,
              items: _voices.map((voice) {
                return DropdownMenuItem(
                  value: voice['name'],
                  child: Text(voice['name'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: _setVoice,
            ),
          ),
          ListTile(
            title: const Text('Playback Speed'),
            subtitle: Slider(
              value: ttsPreferences.speechRate,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: ttsPreferences.speechRate.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  ttsPreferences.speechRate = value;
                });
              },
              onChangeEnd: _setSpeechRate,
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: const Text('System Default'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

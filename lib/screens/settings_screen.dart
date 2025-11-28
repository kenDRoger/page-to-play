import 'package:flutter/material.dart';
import 'package:page_to_play/providers/theme_provider.dart';
import 'package:page_to_play/screens/tutorial_screen.dart';
import 'package:page_to_play/service/tts_service.dart';
import 'package:page_to_play/utilities/constants.dart';
import 'package:provider/provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsGroup(
            title: 'Text-to-Speech',
            children: [
              _buildVoiceSetting(),
              _buildSpeechRateSetting(),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Appearance',
            children: [
              _buildThemeSetting(themeProvider),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: 'Help',
            children: [
              _buildHelpSetting(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title.toUpperCase(), style: kSettingsHeaderTextStyle.apply(color: Theme.of(context).textTheme.bodySmall?.color)),
        ),
        Container(
          decoration: kSettingsCardDecoration.copyWith(color: Theme.of(context).cardColor),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildVoiceSetting() {
    return _buildSettingsItem(
      title: 'Default TTS Voice',
      child: DropdownButton<String>(
        value: ttsPreferences.voiceName,
        items: _voices.map((voice) {
          return DropdownMenuItem(
            value: voice['name'],
            child: Text(voice['name'] ?? 'Unknown', style: kSettingsItemTextStyle.apply(color: Theme.of(context).textTheme.bodyLarge?.color)),
          );
        }).toList(),
        onChanged: _setVoice,
        dropdownColor: Theme.of(context).cardColor,
        underline: Container(),
        isExpanded: true,
      ),
    );
  }

  Widget _buildSpeechRateSetting() {
    return _buildSettingsItem(
      title: 'Playback Speed',
      child: Column(
        children: [
          Slider(
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
          Text(
            '${(ttsPreferences.speechRate * 100).toInt()}% of normal speed',
            style: kSettingsSubItemTextStyle.apply(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(ThemeProvider themeProvider) {
    return _buildSettingsItem(
      title: 'Theme',
      trailing: DropdownButton<ThemeModeOption>(
        value: themeProvider.themeModeOption,
        items: const [
          DropdownMenuItem(
            value: ThemeModeOption.light,
            child: Text('Light'),
          ),
          DropdownMenuItem(
            value: ThemeModeOption.dark,
            child: Text('Dark'),
          ),
          DropdownMenuItem(
            value: ThemeModeOption.system,
            child: Text('System Default'),
          ),
        ],
        onChanged: (ThemeModeOption? newValue) {
          if (newValue != null) {
            themeProvider.setTheme(newValue);
          }
        },
        dropdownColor: Theme.of(context).cardColor,
        underline: Container(),
      ),
    );
  }

  Widget _buildHelpSetting() {
    return _buildSettingsItem(
      title: 'How to Use',
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialScreen()));
      },
    );
  }

  Widget _buildSettingsItem(
      {required String title, Widget? child, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: kSettingsItemTextStyle.apply(color: Theme.of(context).textTheme.bodyLarge?.color)),
      subtitle: child,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

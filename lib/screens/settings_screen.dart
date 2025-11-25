
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(home: SettingsScreen()));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            subtitle: const Text('Google US English'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Playback Speed'),
            subtitle: const Text('1.0x'),
            onTap: () {},
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

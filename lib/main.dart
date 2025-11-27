import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:page_to_play/screens/audiobook_player_screen.dart';
import 'package:page_to_play/screens/conversion_flow_screen.dart';
import 'package:page_to_play/screens/library_screen.dart';
import 'package:page_to_play/screens/sample_importer_screen.dart';
import 'package:page_to_play/screens/settings_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page to Play',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SampleImporterScreen(), // Temporarily set for testing
      routes: {
        '/library': (context) => const LibraryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/conversion': (context) => const ConversionFlowScreen(),
      },
    );
  }
}

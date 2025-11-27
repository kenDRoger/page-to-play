
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:page_to_play/screens/conversion_flow_screen.dart';
import 'package:page_to_play/screens/library_screen.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/library': (context) => const LibraryScreen(),
        '/conversion': (context) => const ConversionFlowScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/library');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your app logo here
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text('Page to Play', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

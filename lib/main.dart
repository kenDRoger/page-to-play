import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:page_to_play/providers/theme_provider.dart';
import 'package:page_to_play/screens/conversion_flow_screen.dart';
import 'package:page_to_play/screens/library_screen.dart';
import 'package:page_to_play/screens/settings_screen.dart';
import 'package:page_to_play/screens/tutorial_screen.dart';
import 'package:page_to_play/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Page to Play',
            theme: kLightTheme,
            darkTheme: kDarkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/library': (context) => const LibraryScreen(),
              '/conversion': (context) => const ConversionFlowScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/tutorial': (context) => const TutorialScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
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
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      await prefs.setBool('first_time', false);
      Timer(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed('/tutorial');
      });
    } else {
      Timer(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed('/library');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kSplashScreenDecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: const Image(image: AssetImage('assets/icon.png')),
              ),
              const SizedBox(height: 20),
              const Text(
                'Page to Play',
                style: kSplashTitleTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

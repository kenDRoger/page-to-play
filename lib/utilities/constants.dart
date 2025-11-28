import 'package:flutter/material.dart';

// Text Styles
const kHeadingTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kSubheadingTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
  color: Colors.white70,
);

const kBodyTextStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.white70,
);

const kPlayerTitleTextStyle = TextStyle(
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kPlayerAuthorTextStyle = TextStyle(
  fontSize: 18.0,
  color: Colors.white70,
  fontStyle: FontStyle.italic,
);

// Splash Screen
const kSplashTitleTextStyle = TextStyle(
  fontSize: 36.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kSplashScreenDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
    ],
  ),
);

// App Theme
final kAppTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF6A11CB),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6A11CB),
    brightness: Brightness.dark,
    secondary: const Color(0xFF2575FC),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    displayLarge: kHeadingTextStyle,
    titleLarge: kSubheadingTextStyle,
    bodyMedium: kBodyTextStyle,
    labelLarge: TextStyle(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF6A11CB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: const Color(0xFF2575FC),
    inactiveTrackColor: Colors.white.withOpacity(0.2),
    thumbColor: Colors.white,
    overlayColor: const Color(0xFF2575FC).withOpacity(0.2),
  ),
);

// Input Decorations
const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Color(0xFF1F1F1F),
  hintStyle: TextStyle(color: Colors.white54),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide.none,
  ),
);

// Ebook Site Links
final kEbookSites = {
  'Project Gutenberg': 'https://www.gutenberg.org/',
  'Standard Ebooks': 'https://standardebooks.org/',
  'ManyBooks': 'https://manybooks.net/',
};

// Tutorial Screen
const kTutorialTitleTextStyle = TextStyle(
  fontSize: 26.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kTutorialContentTextStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.white70,
  height: 1.5,
);

// Audiobook Player Screen
const kPlayerContentTextStyle = TextStyle(
  fontSize: 18.0,
  color: Colors.white70,
  height: 1.6,
);

const kPlayerContentSelectedTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  height: 1.6,
);

final kPlayerSelectedSentenceDecoration = BoxDecoration(
  color: const Color(0xFF2575FC).withOpacity(0.2),
  borderRadius: BorderRadius.circular(8.0),
);

const kPlayerControlIconSize = 32.0;
const kPlayerMainControlIconSize = 48.0;

// Settings Screen
const kSettingsHeaderTextStyle = TextStyle(
  color: Colors.white70,
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
);

final kSettingsCardDecoration = BoxDecoration(
  color: const Color(0xFF1F1F1F),
  borderRadius: BorderRadius.circular(12.0),
);

const kSettingsItemTextStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.white,
);

const kSettingsSubItemTextStyle = TextStyle(
  fontSize: 14.0,
  color: Colors.white54,
);
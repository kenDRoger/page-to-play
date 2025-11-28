import 'package:flutter/material.dart';

// App Color Palette
const kDeepIndigo = Color(0xFF2C466A);
const kVibrantAmber = Color(0xFFE87D38);
const kCreamPaper = Color(0xFFF6F0E0);
const kDarkSlate = Color(0xFF4A4A4A);
const kGildedGold = Color(0xFFC7A868);
const kDarkIndigo = Color(0xFF1A283C);


// Text Styles
const kHeadingTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
);

const kSubheadingTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
);

const kBodyTextStyle = TextStyle(
  fontSize: 16.0,
);

const kPlayerTitleTextStyle = TextStyle(
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

const kPlayerAuthorTextStyle = TextStyle(
  fontSize: 18.0,
  fontStyle: FontStyle.italic,
);

// Splash Screen
const kSplashTitleTextStyle = TextStyle(
  fontSize: 36.0,
  fontWeight: FontWeight.bold,
  color: kCreamPaper,
);

const kSplashScreenDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      kDeepIndigo,
      kVibrantAmber,
    ],
  ),
);

// App Theme
final kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kDeepIndigo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kDeepIndigo,
    brightness: Brightness.dark,
    secondary: kVibrantAmber,
    error: Colors.redAccent,
    onError: kCreamPaper,
  ),
  scaffoldBackgroundColor: kDarkIndigo,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDeepIndigo,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: kCreamPaper,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: kCreamPaper),
  ),
  textTheme: TextTheme(
    displayLarge: kHeadingTextStyle.copyWith(color: kCreamPaper),
    titleLarge: kSubheadingTextStyle.copyWith(color: kCreamPaper),
    bodyMedium: kBodyTextStyle.copyWith(color: kCreamPaper),
    bodySmall: kBodyTextStyle.copyWith(color: kCreamPaper, fontSize: 14.0),
    labelLarge: const TextStyle(color: kCreamPaper),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: kVibrantAmber,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: kVibrantAmber,
    inactiveTrackColor: kCreamPaper,
    thumbColor: kVibrantAmber,
    overlayColor: kVibrantAmber,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: kDeepIndigo,
    hintStyle: TextStyle(color: kCreamPaper),
  ),
  cardColor: kDeepIndigo,
);

final kLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kDeepIndigo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kDeepIndigo,
    brightness: Brightness.light,
    secondary: kVibrantAmber,
    error: Colors.red.shade800,
    onError: kCreamPaper,
  ),
  scaffoldBackgroundColor: kCreamPaper,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDeepIndigo,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: kCreamPaper,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: kCreamPaper),
  ),
  textTheme: TextTheme(
    displayLarge: kHeadingTextStyle.copyWith(color: kDarkSlate),
    titleLarge: kSubheadingTextStyle.copyWith(color: kDarkSlate),
    bodyMedium: kBodyTextStyle.copyWith(color: kDarkSlate),
    bodySmall: kBodyTextStyle.copyWith(color: kDarkSlate, fontSize: 14.0),
    labelLarge: const TextStyle(color: kDarkSlate),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: kVibrantAmber,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: kVibrantAmber,
    inactiveTrackColor: kDarkSlate,
    thumbColor: kDeepIndigo,
    overlayColor: kVibrantAmber,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Colors.white,
    hintStyle: TextStyle(color: kDarkSlate),
  ),
  cardColor: Colors.white,
);


// Input Decorations
const kTextFieldInputDecoration = InputDecoration(
  filled: true,
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
);

const kTutorialContentTextStyle = TextStyle(
  fontSize: 16.0,
  height: 1.5,
);

// Audiobook Player Screen
const kPlayerContentTextStyle = TextStyle(
  fontSize: 18.0,
  height: 1.6,
);

const kPlayerContentSelectedTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  height: 1.6,
);

final kPlayerSelectedSentenceDecoration = BoxDecoration(
  color: kVibrantAmber.withOpacity(0.2),
  borderRadius: BorderRadius.circular(8.0),
);

const kPlayerControlIconSize = 32.0;
const kPlayerMainControlIconSize = 48.0;

// Settings Screen
const kSettingsHeaderTextStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
);

final kSettingsCardDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(12.0),
);

const kSettingsItemTextStyle = TextStyle(
  fontSize: 16.0,
);

const kSettingsSubItemTextStyle = TextStyle(
  fontSize: 14.0,
);

// Conversion Flow Screen
const kSuccessTextStyle = TextStyle(
  color: Colors.green,
  fontSize: 16.0,
);

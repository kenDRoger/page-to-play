import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeModeOption = ThemeModeOption.system;

  ThemeModeOption get themeModeOption => _themeModeOption;

  ThemeMode get themeMode {
    switch (_themeModeOption) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
      default:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 2;
    _themeModeOption = ThemeModeOption.values[themeIndex];
    notifyListeners();
  }

  void setTheme(ThemeModeOption theme) async {
    _themeModeOption = theme;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme', theme.index);
    notifyListeners();
  }
}

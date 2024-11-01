import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_reminder_app/themes/dark_mode.dart';
import 'package:water_reminder_app/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Initially light mode
  ThemeData _themeData = lightMode;

  // Key to store theme preference in shared preferences
  static const String _themePreferenceKey = 'theme_preference';

  // Constructor
  ThemeProvider() {
    // Initialize theme preference when the provider is created
    _loadThemePreference();
  }

  // Get current theme
  ThemeData get themeData => _themeData;

  // Is current theme dark mode
  bool get isDarkMode => _themeData == darkMode;

  // Set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveThemePreference(); // Save theme preference when theme changes
    notifyListeners();
  }

  // Toggle theme
  void toggleTheme() {
    themeData = isDarkMode ? lightMode : darkMode;
  }

  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDark = prefs.getBool(_themePreferenceKey);
    if (isDark != null) {
      _themeData = isDark ? darkMode : lightMode;
      notifyListeners();
    }
  }

  // Save theme preference to shared preferences
  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themePreferenceKey, isDarkMode);
  }
}
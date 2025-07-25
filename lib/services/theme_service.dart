import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service that manages theme mode and persists the user's preference.
class ThemeService extends GetxService {
  static const _prefKey = 'darkMode';

  final themeMode = ThemeMode.light.obs;

  /// Loads the saved theme mode from [SharedPreferences].
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggles between light and dark mode and saves the preference.
  Future<void> toggleDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, isDark);
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

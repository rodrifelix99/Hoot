import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service that manages theme mode and persists the user's preference.
class ThemeService extends GetxService {
  static const _prefKey = 'themeMode';

  /// Current theme mode. Defaults to [ThemeMode.system].
  final themeMode = ThemeMode.system.obs;

  /// Loads the saved theme mode from [SharedPreferences].
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKey);
    themeMode.value =
        index != null ? ThemeMode.values[index] : ThemeMode.system;
  }

  /// Persists and applies the selected [mode].
  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, mode.index);
    themeMode.value = mode;
  }
}

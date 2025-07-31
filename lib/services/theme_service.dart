import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/enums/app_colors.dart';

/// Service that manages theme mode and persists the user's preference.
class ThemeService extends GetxService {
  static const _prefKeyMode = 'themeMode';
  static const _prefKeyColor = 'appColor';

  /// Current theme mode. Defaults to [ThemeMode.system].
  final themeMode = ThemeMode.system.obs;

  /// Current app color.
  final appColor = AppColor.blue.obs;

  /// Loads the saved theme mode and color from [SharedPreferences].
  Future<void> loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_prefKeyMode);
    themeMode.value =
        modeIndex != null ? ThemeMode.values[modeIndex] : ThemeMode.system;

    final colorIndex = prefs.getInt(_prefKeyColor);
    appColor.value =
        colorIndex != null ? AppColor.values[colorIndex] : AppColor.blue;
  }

  /// Persists and applies the selected [mode].
  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyMode, mode.index);
    themeMode.value = mode;
  }

  /// Persists and applies the selected [color].
  Future<void> updateAppColor(AppColor color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyColor, color.index);
    appColor.value = color;
  }

  /// Resets the app color to default.
  Future<void> resetAppColor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyColor);
    appColor.value = AppColor.blue;
  }
}

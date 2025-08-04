import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing and persisting the app's locale.
class LanguageService extends GetxService {
  static const _prefKeyLocale = 'locale';

  /// Currently selected locale.
  final Rx<Locale> locale = Get.deviceLocale?.obs ?? Rx<Locale>(const Locale('en', 'US'));

  /// Loads the saved locale or defaults to [Get.deviceLocale].
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKeyLocale);
    if (code != null) {
      final parts = code.split('-');
      // Validate language code (must be non-empty and match [a-zA-Z]{2,3})
      final languageCode = parts.isNotEmpty ? parts[0] : '';
      final countryCode = parts.length > 1 ? parts[1] : null;
      final isValidLanguage = RegExp(r'^[a-zA-Z]{2,3}$').hasMatch(languageCode);
      if (isValidLanguage) {
        locale.value = Locale.fromSubtags(
          languageCode: languageCode,
          countryCode: countryCode,
        );
      } else {
        locale.value = const Locale('en', 'US');
      }
    } else {
      locale.value = Get.deviceLocale ?? const Locale('en', 'US');
    }
    Get.updateLocale(locale.value);
  }

  /// Persists and applies the selected [newLocale].
  Future<void> updateLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyLocale, newLocale.toLanguageTag());
    locale.value = newLocale;
    Get.updateLocale(newLocale);
  }
}

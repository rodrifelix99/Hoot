import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hoot/pages/settings/controllers/settings_controller.dart';
import 'package:hoot/pages/settings/views/settings_view.dart';
import 'package:hoot/services/theme_service.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/user.dart';

class FakeAuthService extends GetxService implements AuthService {
  @override
  U? get currentUser => null;

  @override
  Future<U?> fetchUser() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserCredential> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserCredential> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> deleteAccount() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Selecting dark mode updates theme', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeService = ThemeService();
    await themeService.loadThemeMode();
    Get.put(themeService);
    Get.put<AuthService>(FakeAuthService());
    Get.put(SettingsController());

    await tester.pumpWidget(
      Obx(() => GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('en'),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode.value,
            home: const SettingsView(),
          )),
    );
    await tester.pumpAndSettle();

    expect(themeService.themeMode.value, ThemeMode.system);
    expect(Theme.of(tester.element(find.byType(SettingsView))).brightness,
        Brightness.light);

    await tester.tap(find.byKey(const Key('themeModeDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(themeService.themeMode.value, ThemeMode.dark);
    expect(Theme.of(tester.element(find.byType(SettingsView))).brightness,
        Brightness.dark);
  });
}

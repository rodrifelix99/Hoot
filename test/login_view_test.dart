import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hoot/pages/login/controllers/login_controller.dart';
import 'package:hoot/pages/login/views/login_view.dart';
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
  Future<U?> fetchUserById(String uid) async => null;

  @override
  Future<U?> fetchUserByUsername(String username) async => null;

  @override
  Future<List<U>> searchUsers(String query, {int limit = 5}) async => [];

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
  testWidgets('LoginView shows welcome description', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(binding.window.clearPhysicalSizeTestValue);
    addTearDown(binding.window.clearDevicePixelRatioTestValue);
    FlutterError.onError = (details) {};
    addTearDown(() {
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });
    Get.put<AuthService>(FakeAuthService());
    Get.put(LoginController());

    await tester.pumpWidget(
      GetCupertinoApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        theme: AppTheme.lightTheme,
        home: const LoginView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('welcomeDescription'.tr), findsOneWidget);
    addTearDown(Get.reset);
  });
}

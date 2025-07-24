import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/error_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../util/routes/app_routes.dart';

class LoginController extends GetxController {
  /// Initiates Google sign in using [AuthService].
  Future<void> signInWithGoogle() async {
    try {
      final credential = await AuthService.signInWithGoogle();
      await _handleUserCredential(credential);
    } catch (e, s) {
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }

  /// Initiates Apple sign in using [AuthService].
  Future<void> signInWithApple() async {
    try {
      final credential = await AuthService.signInWithApple();
      await _handleUserCredential(credential);
    } catch (e, s) {
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }

  Future<void> _handleUserCredential(UserCredential credential) async {
    await AuthService.fetchUser();
    if (AuthService.currentUser != null) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}

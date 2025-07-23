import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/error_service.dart';

class LoginController extends GetxController {
  /// Initiates Google sign in using [AuthService].
  Future<void> signInWithGoogle() async {
    try {
      await AuthService.signInWithGoogle();
    } catch (e, s) {
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }

  /// Initiates Apple sign in using [AuthService].
  Future<void> signInWithApple() async {
    try {
      await AuthService.signInWithApple();
    } catch (e, s) {
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }
}

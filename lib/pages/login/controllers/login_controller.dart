import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/error_service.dart';
import '../../../util/routes/app_routes.dart';

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();

  /// Initiates Google sign in using [AuthService].
  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithGoogle();
      Get.offAllNamed(AppRoutes.home);
    } catch (e, s) {
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }

  /// Initiates Apple sign in using [AuthService].
  Future<void> signInWithApple() async {
    try {
      await _auth.signInWithApple();
      Get.offAllNamed(AppRoutes.home);
    } catch (e, s) {
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }
}

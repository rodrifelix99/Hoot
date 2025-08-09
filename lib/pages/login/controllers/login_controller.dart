import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/analytics_service.dart';
import 'package:hoot/util/routes/app_routes.dart';

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();
  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  /// Initiates Google sign in using [AuthService].
  Future<void> signInWithGoogle() async {
    if (_analytics != null) {
      await _analytics!.logEvent('sign_in_button_pressed',
          parameters: {'provider': 'google'});
    }
    try {
      final result = await _auth.signInWithGoogle();
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in_success', parameters: {
          'provider': 'google',
          if (result.user != null) 'userId': result.user!.uid,
        });
      }
      Get.offAllNamed(AppRoutes.home);
    } catch (e, s) {
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in_failure', parameters: {
          'provider': 'google',
          'error': e.toString(),
        });
      }
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }

  /// Initiates Apple sign in using [AuthService].
  Future<void> signInWithApple() async {
    if (_analytics != null) {
      await _analytics!.logEvent('sign_in_button_pressed',
          parameters: {'provider': 'apple'});
    }
    try {
      final result = await _auth.signInWithApple();
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in_success', parameters: {
          'provider': 'apple',
          if (result.user != null) 'userId': result.user!.uid,
        });
      }
      Get.offAllNamed(AppRoutes.home);
    } catch (e, s) {
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in_failure', parameters: {
          'provider': 'apple',
          'error': e.toString(),
        });
      }
      await ErrorService.reportError(e, message: 'signInFailed'.tr, stack: s);
    }
  }
}

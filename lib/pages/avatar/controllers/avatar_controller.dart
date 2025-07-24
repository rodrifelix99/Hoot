import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../services/error_service.dart';
import '../../../util/routes/app_routes.dart';

class AvatarController extends GetxController {
  /// Completes the onboarding flow and triggers the welcome notification.
  Future<void> finishOnboarding() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final callable =
            FirebaseFunctions.instance.httpsCallable('sendWelcomeNotification');
        await callable.call({'fcmToken': token});
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    } finally {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}

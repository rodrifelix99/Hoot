
import 'package:get/get.dart';
import 'package:hoot/services/onesignal_service.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionController extends GetxController {
  final OneSignalService _oneSignalService = Get.find<OneSignalService>();
  static const _prefKeyNotificationPermissionDenied =
      'notificationPermissionDenied';

  Future<void> requestPermission() async {
    final granted = await _oneSignalService.requestPermission();
    if (!granted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyNotificationPermissionDenied, true);
    }
    Get.offAllNamed(AppRoutes.home);
  }
}

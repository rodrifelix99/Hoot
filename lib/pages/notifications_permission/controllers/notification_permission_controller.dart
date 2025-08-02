import 'package:get/get.dart';
import 'package:hoot/services/onesignal_service.dart';
import 'package:hoot/util/routes/app_routes.dart';

class NotificationPermissionController extends GetxController {
  final OneSignalService _oneSignalService = Get.find<OneSignalService>();

  Future<void> requestPermission() async {
    await _oneSignalService.requestPermission();
    Get.offAllNamed(AppRoutes.home);
  }
}

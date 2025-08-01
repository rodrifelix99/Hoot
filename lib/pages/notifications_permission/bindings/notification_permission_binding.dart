import 'package:get/get.dart';
import '../controllers/notification_permission_controller.dart';

class NotificationPermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationPermissionController());
  }
}

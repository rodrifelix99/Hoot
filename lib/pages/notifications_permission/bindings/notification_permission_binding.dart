import 'package:get/get.dart';
import 'package:hoot/pages/notifications_permission/controllers/notification_permission_controller.dart';

class NotificationPermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationPermissionController());
  }
}

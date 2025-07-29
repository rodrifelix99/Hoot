import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../util/routes/app_routes.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _verifyUser();
  }

  Future<void> _verifyUser() async {
    final user = await _auth.fetchUser();
    if (user == null || user.isNewUser) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }
    if (user.isUninvited) {
      Get.offAllNamed(AppRoutes.invitation);
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 2 && Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().markAllAsRead();
    }
  }
}

import 'package:get/get.dart';
import 'package:screen_corner_radius/screen_corner_radius.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/onesignal_service.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final _auth = Get.find<AuthService>();

  final RxDouble screenRadius = 32.0.obs;

  @override
  void onInit() {
    super.onInit();
    _verifyUser();
  }

  Future<void> _setRadius() async {
    final ScreenRadius screenRadius = await ScreenCornerRadius.get();
    // await 2 seconds to ensure the screen corner radius is available
    await Future.delayed(const Duration(seconds: 2));
    if (screenRadius.bottomLeft == 0.0) {
      this.screenRadius.value = 32.0;
      return;
    }
    this.screenRadius.value = screenRadius.bottomLeft;
  }

  Future<void> _verifyUser() async {
    final user = await _auth.fetchUser();
    if (user == null || user.isNewUser) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }
    if (user.isUninvited) {
      Get.offAllNamed(AppRoutes.invitation);
      return;
    }

    final oneSignal = Get.find<OneSignalService>();
    await oneSignal.login(user.uid);
    if (await oneSignal.canRequestPermission()) {
      Get.toNamed(AppRoutes.notificationsPermission);
    }
    _setRadius();
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 2 && Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().markAllAsRead();
    }
  }
}

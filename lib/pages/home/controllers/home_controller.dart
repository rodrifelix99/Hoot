import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/onesignal_service.dart';
import 'package:hoot/services/quick_actions_service.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:screen_corner_radius/screen_corner_radius.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final selectedIndex = 0.obs;
  final _auth = Get.find<AuthService>();

  final RxDouble screenRadius = 32.0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _verifyUser();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OneSignalService>().clearBadge();
    }
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
    final prefs = await SharedPreferences.getInstance();
    const prefKey = 'notificationPermissionDenied';
    final permissionDenied = prefs.getBool(prefKey) ?? false;
    if (!permissionDenied && await oneSignal.canRequestPermission()) {
      Get.offAllNamed(AppRoutes.notificationsPermission);
      return;
    }

    if (Platform.isIOS) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    final quickActions = Get.find<QuickActionsService>();
    quickActions.handlePendingAction();
    oneSignal.handlePendingNotification();
    await oneSignal.clearBadge();

    _setRadius();
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 2 && Get.isRegistered<NotificationsController>()) {
      final controller = Get.find<NotificationsController>();
      controller.refreshNotifications();
      controller.markAllAsRead();
    }
  }
}

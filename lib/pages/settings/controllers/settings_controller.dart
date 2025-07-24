import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../../../services/dialog_service.dart';
import '../../../services/error_service.dart';
import '../../../util/routes/app_routes.dart';

class SettingsController extends GetxController {
  final _auth = Get.find<AuthService>();

  /// Signs out the user after confirmation.
  Future<void> signOut(BuildContext context) async {
    final confirmed = await DialogService.confirm(
      context: context,
      title: 'signOut'.tr,
      message: 'signOutConfirmation'.tr,
      okLabel: 'signOut'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (!confirmed) return;
    try {
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    }
  }
}

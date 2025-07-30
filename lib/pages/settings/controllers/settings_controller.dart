import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../services/auth_service.dart';
import '../../../services/dialog_service.dart';
import '../../../services/error_service.dart';
import '../../../services/toast_service.dart';
import '../../../services/theme_service.dart';
import '../../../util/routes/app_routes.dart';

class SettingsController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _theme = Get.find<ThemeService>();

  final version = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version.value = info.version;
  }

  ThemeMode get themeMode => _theme.themeMode.value;

  void updateThemeMode(ThemeMode? mode) {
    if (mode == null) return;
    _theme.updateThemeMode(mode);
  }

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

  void goToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  Future<void> findFriends() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      ToastService.showError('contactsPermission'.tr);
      return;
    }
    Get.toNamed(AppRoutes.contacts);
  }

  Future<void> deleteAccount(BuildContext context) async {
    var confirmed = await DialogService.confirm(
      context: context,
      title: 'deleteAccount'.tr,
      message: 'deleteAccountConfirmation'.tr,
      okLabel: 'delete'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (!confirmed) return;

    confirmed = await DialogService.confirmWithText(
      context: context,
      title: 'deleteAccount'.tr,
      message: 'deleteAccountVerify'.tr,
      expectedWord: 'delete',
      okLabel: 'delete'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (!confirmed) return;
    try {
      await _auth.deleteAccount();
      ToastService.showSuccess('deleteAccountSuccess'.tr);
      Get.offAllNamed(AppRoutes.login);
    } catch (e, s) {
      await ErrorService.reportError(e,
          message: 'deleteAccountFailed'.tr, stack: s);
    }
  }
}

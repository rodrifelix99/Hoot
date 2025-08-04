import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/invitation_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/util/routes/app_routes.dart';

class InvitationController extends GetxController {
  final InvitationService _invitationService;
  final AuthService _authService;

  InvitationController(
      {InvitationService? invitationService, AuthService? authService})
      : _invitationService = invitationService ?? InvitationService(),
        _authService = authService ?? Get.find<AuthService>();

  final TextEditingController codeController = TextEditingController();
  final RxBool verifying = false.obs;
  final RxBool isCrossFade = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 20), () {
      isCrossFade.value = true;
    });
  }

  Future<void> verifyCode() async {
    if (verifying.value) return;
    final code = codeController.text.trim();
    if (code.isEmpty) return;
    verifying.value = true;
    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        ToastService.showError('somethingWentWrong'.tr);
        return;
      }
      final success = await _invitationService.useInvitationCode(uid, code);
      if (success) {
        await _authService.refreshUser();
        Get.offAllNamed(AppRoutes.home);
      } else {
        ToastService.showError('invalidInvitationCode'.tr);
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    } finally {
      verifying.value = false;
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}

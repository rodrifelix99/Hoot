import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:hoot/services/toast_service.dart';
import '../util/routes/app_routes.dart';

class SignInWithAppleButton extends StatefulWidget {
  const SignInWithAppleButton({super.key});

  @override
  State<SignInWithAppleButton> createState() => _SignInWithAppleButtonState();
}

class _SignInWithAppleButtonState extends State<SignInWithAppleButton> {
  Future _signInWithApple() async {
    String code = await Get.find<AuthController>().signInWithApple();
    if (code != "success" && code != "new-user") {
      setState(() {
        ToastService.showError('signInFailed'.tr);
      });
    } else if (code == "new-user") {
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return SignInButton(
        Buttons.AppleDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () => _signInWithApple(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

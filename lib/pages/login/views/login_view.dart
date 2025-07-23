import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart' as buttons;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buttons.SignInButton(
              buttons.Buttons.google,
              onPressed: controller.signInWithGoogle,
            ),
            const SizedBox(height: 16),
            SignInWithAppleButton(
              onPressed: controller.signInWithApple,
            ),
          ],
        ),
      ),
    );
  }
}

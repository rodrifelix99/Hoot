import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart' as buttons;
import 'package:get/get.dart';

import 'package:hoot/pages/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'welcomeDescription'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  buttons.SignInButton(
                    buttons.Buttons.Google,
                    onPressed: controller.signInWithGoogle,
                  ),
                  buttons.SignInButton(
                    buttons.Buttons.Apple,
                    onPressed: controller.signInWithApple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

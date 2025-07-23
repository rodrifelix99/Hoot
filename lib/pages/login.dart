import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/sign_in_with_google.dart';
import '../components/sign_in_with_apple.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('signIn'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SignInWithGoogleButton(),
            SizedBox(height: 16),
            SignInWithAppleButton(),
          ],
        ),
      ),
    );
  }
}

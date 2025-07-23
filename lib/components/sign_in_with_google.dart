import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignInWithGoogleButton extends StatefulWidget {
  const SignInWithGoogleButton({super.key});

  @override
  State<SignInWithGoogleButton> createState() => _SignInWithGoogleButtonState();
}

class _SignInWithGoogleButtonState extends State<SignInWithGoogleButton> {
  Future<void> _signInWithGoogle() async {
    final auth = Get.find<AuthController>();
    bool success = await auth.signInWithGoogle();
    if (!success) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signInFailed'.tr),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    } else if (auth.user?.uid == 'HOOT-IS-AWESOME') {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/welcome', (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.Google,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      onPressed: _signInWithGoogle,
    );
  }
}

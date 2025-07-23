import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.signInFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    } else if (code == "new-user") {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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

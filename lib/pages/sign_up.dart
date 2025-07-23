import 'package:hoot/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoot/services/error_service.dart';
import 'package:get/get.dart';

import 'package:hoot/components/sign_in_with_apple.dart';
import 'package:hoot/app/controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _isValid() {
    return _emailController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 6 &&
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text &&
        !_isLoading;
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    String code = await Get.find<AuthController>().signUpWithEmailAndPassword(
      _emailController.text,
      _passwordController.text
    );

    if (code != 'success') {
      String errorMessage = '';
      switch (code) {
        case "invalid-email":
          errorMessage = 'errorInvalidEmail'.tr;
          break;
        case "email-already-in-use":
          errorMessage = 'errorEmailAlreadyInUse'.tr;
          break;
        case "weak-password":
          errorMessage = 'errorWeakPassword'.tr;
          break;
        default:
          errorMessage = 'errorUnknown'.tr;
      }

      setState(() {
        _isLoading = false;
        TextInput.finishAutofillContext();
        ToastService.showToast(context, errorMessage, true);
      });
    } else {
      Get.offAllNamed('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('signUp'.tr)),
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 150),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (value) => setState(() {}),
                          onEditingComplete: () => FocusScope.of(context).nextFocus(),
                          decoration: InputDecoration(
                            labelText: 'email'.tr,
                          ),
                        ),
                        _emailController.text.isNotEmpty && !_emailController.text.contains('@')
                            ? Text(
                            'emailInvalid'.tr,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error
                            )
                        )
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          onChanged: (value) => setState(() {}),
                          onEditingComplete: () => FocusScope.of(context).nextFocus(),
                          decoration: InputDecoration(
                            labelText: 'password'.tr,
                          ),
                        ),
                        _passwordController.text.isNotEmpty && _passwordController.text.length < 6
                            ? Text(
                            'passwordTooShort'.tr,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error
                            )
                        )
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (value) => _isValid() ? _signUp() : null,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'repeatPassword'.tr,
                          ),
                        ),
                        _confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text != _passwordController.text
                            ? Text(
                            'passwordsDontMatch'.tr,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error
                            )
                        )
                            : const SizedBox(),
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'bySigningUpYouAgreeToOur'.tr,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                ),
                              ),
                              TextButton(
                                  onPressed: () => Get.toNamed('/terms_of_service'),
                                  child: Text(
                                    'termsOfService'.tr,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary
                                    ),
                                  )
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _isValid() && !_isLoading ? _signUp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid() ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      child: !_isLoading ? Text(
                          'signUp'.tr,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                      ) : CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 8),
                    const SignInWithAppleButton(),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/error_service.dart';
import 'package:provider/provider.dart';

import '../components/sign_in_with_apple.dart';
import '../services/auth.dart';

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

    String code = await Provider.of<AuthProvider>(context, listen: false).signUpWithEmailAndPassword(
      _emailController.text,
      _passwordController.text
    );

    if (code != 'success') {
      String errorMessage = '';
      switch (code) {
        case "invalid-email":
          errorMessage = AppLocalizations.of(context)!.errorInvalidEmail;
          break;
        case "email-already-in-use":
          errorMessage = AppLocalizations.of(context)!.errorEmailAlreadyInUse;
          break;
        case "weak-password":
          errorMessage = AppLocalizations.of(context)!.errorWeakPassword;
          break;
        default:
          errorMessage = AppLocalizations.of(context)!.errorUnknown;
      }

      setState(() {
        _isLoading = false;
        ToastService.showToast(context, errorMessage, true);
      });
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.signUp)),
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => setState(() {}),
                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                        ),
                      ),
                      _emailController.text.isNotEmpty && !_emailController.text.contains('@')
                          ? Text(
                          AppLocalizations.of(context)!.emailInvalid,
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
                        onChanged: (value) => setState(() {}),
                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                        ),
                      ),
                      _passwordController.text.isNotEmpty && _passwordController.text.length < 6
                          ? Text(
                          AppLocalizations.of(context)!.passwordTooShort,
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
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.repeatPassword,
                        ),
                      ),
                      _confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text != _passwordController.text
                          ? Text(
                          AppLocalizations.of(context)!.passwordsDontMatch,
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
                              AppLocalizations.of(context)!.bySigningUpYouAgreeToOur,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                              ),
                            ),
                            TextButton(
                                onPressed: () => Navigator.of(context).pushNamed('/terms_of_service'),
                                child: Text(
                                  AppLocalizations.of(context)!.termsOfService,
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
                          AppLocalizations.of(context)!.signUp,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                      ) : CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 8),
                    SignInWithAppleButton(),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}

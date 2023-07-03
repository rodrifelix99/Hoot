import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';

import '../components/sign_in_with_apple.dart';
import '../services/auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _isValid() {
    return _displayNameController.text.isNotEmpty &&
        _displayNameController.text.length >= 3 &&
        _emailController.text.isNotEmpty &&
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
      _displayNameController.text,
      _emailController.text,
      _passwordController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMessage, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onError)),
                backgroundColor: Theme.of(context).colorScheme.error
            )
        );
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
                        controller: _displayNameController,
                        autocorrect: true,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => setState(() {}),
                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.displayName,
                        ),
                      ),
                      _displayNameController.text.isNotEmpty && _displayNameController.text.length < 3
                          ? Text(
                        AppLocalizations.of(context)!.displayNameTooShort,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            color: Theme.of(context).colorScheme.error
                        ),
                      )
                          : const SizedBox(),
                      const SizedBox(height: 16),
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
                          style: Theme.of(context).textTheme.caption?.copyWith(
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
                          style: Theme.of(context).textTheme.caption?.copyWith(
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
                          style: Theme.of(context).textTheme.caption?.copyWith(
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
                              style: Theme.of(context).textTheme.caption?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                              ),
                            ),
                            TextButton(
                                onPressed: () => Navigator.of(context).pushNamed('/terms_of_service'),
                                child: Text(
                                  AppLocalizations.of(context)!.termsOfService,
                                  style: Theme.of(context).textTheme.caption?.copyWith(
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _isLoading ?
                    ElevatedButton(
                      onPressed: () {},
                      child: const Icon(Icons.cloud_circle),
                    ) : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid() ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.signUp,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                      ),
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

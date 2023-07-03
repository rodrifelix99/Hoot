import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:hoot/components/sign_in_with_apple.dart';
import 'package:hoot/services/auth.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isValid() {
    return _emailController.text.isNotEmpty && _emailController.text.contains('@') && _passwordController.text.isNotEmpty && _passwordController.text.length >= 6;
  }

  Future _signInWithEmailAndPassword() async {
    setState(() => _isLoading = true);
    String code = await Provider.of<AuthProvider>(context, listen: false).signInWithEmailAndPassword(_emailController.text, _passwordController.text);

    if (code != "success" && code != "new-user") {
      setState(() => _isLoading = false);
      String error = "";
      switch (code) {
        case "invalid-email":
          error = AppLocalizations.of(context)!.emailInvalid;
          break;
        case "user-disabled":
          error = AppLocalizations.of(context)!.userDisabled;
          break;
        case "user-not-found":
          error = AppLocalizations.of(context)!.errorUserNotFound;
          break;
        case "wrong-password":
          error = AppLocalizations.of(context)!.errorWrongPassword;
          break;
        default:
          error = AppLocalizations.of(context)!.errorUnknown;
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (code == "new-user") {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.signIn)),
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
                    onPressed: _signInWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValid() ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    child: Text(
                        AppLocalizations.of(context)!.signIn,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                    ),
                  ),
                  const SizedBox(height: 8),
                  SignInWithAppleButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

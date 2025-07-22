import 'package:hoot/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/components/sign_in_with_apple.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:hoot/services/error_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _countryCode = 'US';
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  bool _isValid() {
    // _phoneNumberController.text.isNotEmpty && _phoneNumberController.text.length >= 6 && _phoneNumberController.text.length <= 15 && is only numbers
    return _phoneNumberController.text.isNotEmpty && _phoneNumberController.text.length >= 6 && _phoneNumberController.text.length <= 15 && RegExp(r'^[0-9]+$').hasMatch(_phoneNumberController.text);
  }

  @override
  void initState() {
    // get country code for phone number
    final String isoCode = Localizations.localeOf(context).countryCode ?? 'US';
    _countryCode = isoCode;
    super.initState();
  }

  Future _signInWithEmailAndPassword() async {
    setState(() => _isLoading = true);
    String code = ''; //await Get.find<AuthController>().signInWithEmailAndPassword(_emailController.text, _passwordController.text);

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
          error = code;
          break;
      }
      ToastService.showToast(context, error, true);
    } else if (code == "new-user") {
      TextInput.finishAutofillContext();
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      TextInput.finishAutofillContext();
      Get.offAllNamed(AppRoutes.home);
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
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InternationalPhoneNumberInput(
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useEmoji: true,
                          setSelectorButtonAsPrefixIcon: true,
                          leadingPadding: 16,
                        ),
                        onInputChanged: (PhoneNumber number) {
                          print(_phoneNumberController.text);
                        },
                        selectorTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          if (value!.isEmpty || value.length < 6) {
                            return AppLocalizations.of(context)!.phoneNumberInvalid;
                          }
                          return null;
                        },
                        autofillHints: const [AutofillHints.telephoneNumber],
                        initialValue: PhoneNumber(isoCode: _countryCode),
                        errorMessage: AppLocalizations.of(context)!.phoneNumberInvalid,
                        textFieldController: _phoneNumberController,

                        inputDecoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.phoneNumber,
                        ),
                        formatInput: false,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
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
                                onPressed: () => Get.toNamed(AppRoutes.terms),
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
                    onPressed: _isValid() && !_isLoading ? _signInWithEmailAndPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValid() ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    child: !_isLoading ? Text(
                        AppLocalizations.of(context)!.signIn,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                    ) : CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 8),
                  const SignInWithAppleButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

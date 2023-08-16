import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:octo_image/octo_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../services/error_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String version = "";
  late AuthProvider _authProvider;
  late VoidCallback _authProviderListener;

  Future _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = "${packageInfo.packageName}\n${packageInfo.version} (${packageInfo.buildNumber})";
    });
    print(version);
  }

  @override
  void initState() {
    _loadVersion();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProviderListener = () async  {
        if (_authProvider.isSignedIn) {
          await Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      };
      _authProvider.addListener(_authProviderListener);
      _authProvider.phoneNumber = PhoneNumber(isoCode: WidgetsBinding.instance.window.locale.countryCode ?? 'US');
    });
  }

  @override
  void dispose() {
    _authProvider.removeListener(_authProviderListener);
    super.dispose();
  }

  void _next() {
    if (_authProvider.phoneNumber.phoneNumber != null) {
      _authProvider.removeListener(_authProviderListener);
      Navigator.pushNamed(context, '/verify');
    } else {
      ToastService.showToast(context, AppLocalizations.of(context)!.phoneNumberInvalid, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
              child: OctoImage(
                  image: const AssetImage('assets/login/bg.jpg'),
                  placeholderBuilder: OctoPlaceholder.blurHash(
                      'L74MSacI5Ro#L}jDxaWBEdjD,?ad'),
                  fit: BoxFit.cover,
                ),
              ),
          Positioned.fill(
            child: Center(
              child: Text(AppLocalizations.of(context)!.appName,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black12,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                  fontSize: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 50,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          _authProvider.phoneNumber = number;
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useEmoji: true,
                          setSelectorButtonAsPrefixIcon: true,
                          leadingPadding: 16,
                        ),
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
                        initialValue: _authProvider.phoneNumber,
                        errorMessage: AppLocalizations.of(context)!.phoneNumberInvalid,
                        inputDecoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.phoneNumber,
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                          errorStyle: const TextStyle(color: Colors.redAccent),
                        ),
                        hintText: AppLocalizations.of(context)!.phoneNumber,
                        formatInput: false,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        onSubmit: () => _next(),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            AppLocalizations.of(context)!.bySigningUpYouAgreeToOur,
                            style: const TextStyle(color: Colors.white)
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/terms_of_service'),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          ),
                          child: Text(
                              AppLocalizations.of(context)!.termsOfService,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          )
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

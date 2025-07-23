import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:octo_image/octo_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'package:hoot/app/routes/app_routes.dart';

import 'package:hoot/services/error_service.dart';
import '../app/utils/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String version = "";
  late AuthController _authController;
  late VoidCallback _authControllerListener;

  Future _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version =
          "${packageInfo.packageName}\n${packageInfo.version} (${packageInfo.buildNumber})";
    });
    FirebaseCrashlytics.instance.log(version);
  }

  @override
  void initState() {
    _loadVersion();
    _authController = Get.find<AuthController>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authControllerListener = () async {
        if (_authController.isSignedIn) {
          await Get.offAllNamed(AppRoutes.home);
        }
      };
      _authController.addListener(_authControllerListener);
      _authController.phoneNumber = PhoneNumber(
          isoCode: WidgetsBinding.instance.window.locale.countryCode ?? 'US');
    });
  }

  @override
  void dispose() {
    _authController.removeListener(_authControllerListener);
    super.dispose();
  }

  void _next() {
    if (_authController.phoneNumber.phoneNumber != null) {
      _authController.removeListener(_authControllerListener);
      Get.toNamed(AppRoutes.verify);
    } else {
      ToastService.showToast(
          context, 'phoneNumberInvalid'.tr, true);
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
                placeholderBuilder:
                    OctoPlaceholder.blurHash('L74MSacI5Ro#L}jDxaWBEdjD,?ad'),
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  'appName'.tr,
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
                          _authController.phoneNumber = number;
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useEmoji: true,
                          setSelectorButtonAsPrefixIcon: true,
                          leadingPadding: 16,
                        ),
                        selectorTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          if (value!.isEmpty || value.length < 6) {
                            return 'phoneNumberInvalid'.tr;
                          }
                          return null;
                        },
                        autofillHints: const [AutofillHints.telephoneNumber],
                        initialValue: _authController.phoneNumber,
                        errorMessage:
                            'phoneNumberInvalid'.tr,
                        inputDecoration: InputDecoration(
                          hintText: 'phoneNumber'.tr,
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.5)),
                          errorStyle: const TextStyle(color: Colors.redAccent),
                        ),
                        hintText: 'phoneNumber'.tr,
                        formatInput: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        onSubmit: () => _next(),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('bySigningUpYouAgreeToOur'.tr,
                              style: const TextStyle(color: Colors.white)),
                          TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.terms),
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
                                overlayColor: MaterialStateProperty.all<Color>(
                                    Colors.transparent),
                              ),
                              child: Text(
                                  'termsOfService'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

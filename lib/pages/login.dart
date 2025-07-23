import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/components/sign_in_with_google.dart';
import 'package:hoot/components/sign_in_with_apple.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'package:hoot/app/routes/app_routes.dart';

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
    });
  }

  @override
  void dispose() {
    _authController.removeListener(_authControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/login/bg.jpg',
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
                      const SignInWithGoogleButton(),
                      const SizedBox(height: 8),
                      const SignInWithAppleButton(),
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
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
                                overlayColor: WidgetStateProperty.all<Color>(
                                    Colors.transparent),
                              ),
                              child: Text('termsOfService'.tr,
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

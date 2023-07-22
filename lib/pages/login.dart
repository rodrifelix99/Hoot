import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:octo_image/octo_image.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String version = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = "${packageInfo.version} (${packageInfo.buildNumber})";
    });
  }

  @override
  void initState() {
    _loadVersion();
    super.initState();
    _auth.authStateChanges().listen(_onAuthStateChanged); // Add listener
  }

  _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.appName,
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
                  Text("Beta - $version",
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.createMyAccount,
                          style: const TextStyle(color: Colors.black)
                      )
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.alreadyHaveAnAccount,
                          style: const TextStyle(color: Colors.white)
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signin'),
                        child: Text(
                            AppLocalizations.of(context)!.signIn,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white)
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}

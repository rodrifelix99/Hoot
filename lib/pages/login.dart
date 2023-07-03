import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:octo_image/octo_image.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                      child: Text(
                          AppLocalizations.of(context)!.createMyAccount,
                          style: const TextStyle(color: Colors.black)
                      )
                  ),
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

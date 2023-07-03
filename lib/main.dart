import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hoot/pages/home.dart';
import 'package:hoot/pages/sign_in.dart';
import 'package:hoot/pages/sign_up.dart';
import 'package:hoot/pages/terms.dart';
import 'package:hoot/pages/welcome.dart';
import 'package:hoot/services/auth.dart';
import 'package:hoot/theme/theme.dart';
import 'firebase_options.dart';
import 'package:hoot/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Hoot',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
            ],
            home: AnimatedSplashScreen(
              nextScreen: authProvider.isSignedIn ? HomePage() : LoginPage(),
              splash: Image.asset('assets/logo.png'),
              splashTransition: SplashTransition.fadeTransition,
            ),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(builder: (context) => LoginPage());
                case '/home':
                  return MaterialPageRoute(builder: (context) => HomePage());
                case '/signup':
                  return MaterialPageRoute(builder: (context) => SignUpPage());
                case '/signin':
                  return MaterialPageRoute(builder: (context) => SignInPage());
                case '/terms_of_service':
                  return MaterialPageRoute(builder: (context) => TermsOfService());
                case '/welcome':
                  return MaterialPageRoute(builder: (context) => WelcomePage());
                default:
                  return MaterialPageRoute(builder: (context) => LoginPage());
              }
            },
          );
        },
      ),
    ),
  );
}

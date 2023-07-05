import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/create_post.dart';
import 'package:hoot/pages/home.dart';
import 'package:hoot/pages/profile.dart';
import 'package:hoot/pages/sign_in.dart';
import 'package:hoot/pages/sign_up.dart';
import 'package:hoot/pages/terms.dart';
import 'package:hoot/pages/welcome.dart';
import 'package:hoot/services/auth.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:hoot/theme/theme.dart';
import 'firebase_options.dart';
import 'package:hoot/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages here
  // ...
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Request permission for notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
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
                case '/create':
                  return MaterialPageRoute(
                    builder: (context) {
                      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
                      return CreatePostPage(feedProvider: feedProvider);
                    },
                  );
                case '/profile':
                  final U user = settings.arguments as U;
                  return MaterialPageRoute(builder: (context) => ProfilePage(user: user));
                default:
                  return MaterialPageRoute(builder: (context) => HomePage());
              }
            },
          );
        },
      ),
    ),
  );
}

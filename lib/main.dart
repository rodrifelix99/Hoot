import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app/utils/logger.dart';
import 'package:hoot/pages/home.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/initial_binding.dart';
import 'package:hoot/theme/theme.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages here
  // ...
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Request permission for notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    FirebaseCrashlytics.instance.log('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    FirebaseCrashlytics.instance.log('User granted provisional permission');
  } else {
    FirebaseCrashlytics.instance
        .log('User declined or has not accepted permission');
  }

  runZonedGuarded(() {
    runApp(
      GetMaterialApp(
        title: 'Hoot',
        initialBinding: InitialBinding(),
        getPages: AppPages.pages,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('pt'),
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        home: AnimatedSplashScreen(
          nextScreen: const HomePage(),
          splash: 'assets/logo_white.png',
          backgroundColor: const Color(0xFF000000),
          splashTransition: SplashTransition.slideTransition,
          pageTransitionType: PageTransitionType.rightToLeft,
        ),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

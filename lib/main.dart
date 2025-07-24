import 'dart:async';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_pages.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/initial_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:toastification/toastification.dart';
import 'firebase_options.dart';

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
      ToastificationWrapper(
        child: GetMaterialApp(
          title: 'Hoot',
          initialBinding: InitialBinding(),
          getPages: AppPages.pages,
          initialRoute: AppRoutes.login,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
        ),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

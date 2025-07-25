import 'dart:async';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_pages.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/dependency_injector.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:toastification/toastification.dart';
import 'services/theme_service.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DependencyInjector.init();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;


  final themeService = Get.find<ThemeService>();

  runZonedGuarded(() {
    runApp(
      ToastificationWrapper(
        child: Obx(() => GetMaterialApp(
          title: 'Hoot',
          debugShowCheckedModeBanner: false,
          getPages: AppPages.pages,
          initialRoute: AppRoutes.home,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode.value,
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
        )),
      ),
    );
    FlutterNativeSplash.remove();
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

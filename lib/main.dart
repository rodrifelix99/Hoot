import 'dart:async';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_pages.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/dependency_injector.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/enums/app_colors.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hoot/services/theme_service.dart';
import 'package:hoot/services/quick_actions_service.dart';
import 'package:hoot/services/onesignal_service.dart';
import 'package:hoot/firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: 'assets/.env');
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
    );
    await DependencyInjector.init();
    final quickActions = Get.find<QuickActionsService>();
    final oneSignal = Get.find<OneSignalService>();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    TenorGifPicker.init(
      apiKey: dotenv.env['TENOR_API_KEY'] ?? '',
      locale: Get.locale?.toLanguageTag() ?? 'en',
      country: Get.deviceLocale?.countryCode ?? 'US',
    );

    timeago.setLocaleMessages('es', timeago.EsMessages());
    timeago.setLocaleMessages('pt', timeago.PtBrMessages());
    timeago.setLocaleMessages('pt-BR', timeago.PtBrMessages());
    timeago.setLocaleMessages('pt-PT', timeago.PtBrMessages());

    final themeService = Get.find<ThemeService>();
    runApp(
      Portal(
        child: ToastificationWrapper(
          child: Obx(
            () => GetMaterialApp(
              title: 'Hoot',
              debugShowCheckedModeBanner: false,
              getPages: AppPages.pages,
              initialRoute: AppRoutes.home,
              theme: AppTheme.lightTheme(themeService.appColor.value.color),
              darkTheme: AppTheme.darkTheme(themeService.appColor.value.color),
              themeMode: themeService.themeMode.value,
              translations: AppTranslations(),
              locale: Get.deviceLocale,
              fallbackLocale: const Locale('en', 'US'),
            ),
          ),
        ),
      ),
    );
    quickActions.handlePendingAction();
    oneSignal.handlePendingNotification();
    FlutterNativeSplash.remove();
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

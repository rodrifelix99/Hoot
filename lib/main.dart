import 'dart:async';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_pages.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/dependency_injector.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'services/theme_service.dart';
import 'services/quick_actions_service.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: 'assets/.env');
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await DependencyInjector.init();
    final quickActions = Get.find<QuickActionsService>();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    TenorGifPicker.init(
      apiKey: dotenv.env['TENOR_API_KEY'] ?? '',
      locale: Get.locale?.toLanguageTag() ?? 'en',
      country: Get.deviceLocale?.countryCode ?? 'US',
    );

    timeago.setLocaleMessages('es', timeago.EsMessages());
    timeago.setLocaleMessages('pt', timeago.PtBrMessages());
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

    final themeService = Get.find<ThemeService>();
    runApp(
      Portal(
        child: ToastificationWrapper(
          child: Obx(
            () => GetCupertinoApp(
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
            ),
          ),
        ),
      ),
    );
    quickActions.handlePendingAction();
    FlutterNativeSplash.remove();
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hoot/mock/mock_dependency_injector.dart';
import 'package:hoot/mock/mock_app_pages.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/services/theme_service.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await MockDependencyInjector.init();

    TenorGifPicker.init(
      apiKey: '',
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
              getPages: MockAppPages.pages,
              initialRoute: AppRoutes.home,
              theme: AppTheme.lightTheme(themeService.appColor.value.color),
              darkTheme: AppTheme.darkTheme(themeService.appColor.value.color),
              themeMode: themeService.themeMode.value,
              translations: AppTranslations(),
              locale: Get.deviceLocale,
              fallbackLocale: const Locale('en', 'US'),
              builder: (context, child) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    FlutterNativeSplash.remove();
  }, (error, stack) {});
}

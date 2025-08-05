import 'package:get/get.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/theme_service.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_manager.dart';
import 'package:hoot/services/quick_actions_service.dart';
import 'package:hoot/services/onesignal_service.dart';
import 'package:hoot/services/language_service.dart';
import 'package:hoot/services/news_service.dart';

/// Registers global dependencies for the application.
class DependencyInjector {
  DependencyInjector._();

  /// Initializes dependencies and performs startup tasks.
  static Future<void> init() async {
    final auth = Get.put(AuthService(), permanent: true);
    await auth.fetchUser();
    Get.put(FeedService(), permanent: true);
    Get.put(PostService(), permanent: true);
    Get.put(SubscriptionService(), permanent: true);
    Get.put(FeedRequestService(), permanent: true);
    Get.put(SubscriptionManager(), permanent: true);
    Get.put(QuickActionsService(), permanent: true);
    Get.put(OneSignalService(), permanent: true);
    final theme = Get.put(ThemeService(), permanent: true);
    await theme.loadThemeSettings();
    final language = Get.put(LanguageService(), permanent: true);
    await language.loadLocale();
    Get.put(NewsService(), permanent: true);
    await Get.find<OneSignalService>().init();
    await Get.find<QuickActionsService>().init();
  }
}

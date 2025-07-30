import 'package:get/get.dart';
import 'services/auth_service.dart';
import 'services/feed_service.dart';
import 'services/theme_service.dart';
import 'services/post_service.dart';
import 'services/subscription_service.dart';
import 'services/feed_request_service.dart';
import 'services/quick_actions_service.dart';

/// Registers global dependencies for the application.
class DependencyInjector {
  DependencyInjector._();

  /// Initializes dependencies and performs startup tasks.
  static Future<void> init() async {
    final auth = Get.put(AuthService(), permanent: true);
    await auth.fetchUser();
    Get.put<BaseFeedService>(FeedService(), permanent: true);
    Get.put<BasePostService>(PostService(authService: auth), permanent: true);
    Get.put(SubscriptionService(), permanent: true);
    Get.put(FeedRequestService(), permanent: true);
    Get.put(QuickActionsService(), permanent: true);
    final theme = Get.put(ThemeService(), permanent: true);
    await theme.loadThemeMode();
    await Get.find<QuickActionsService>().init();
  }
}

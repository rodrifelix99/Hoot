import 'package:get/get.dart';
import 'services/auth_service.dart';
import 'services/feed_service.dart';
import 'services/theme_service.dart';

/// Registers global dependencies for the application.
class DependencyInjector {
  DependencyInjector._();

  /// Initializes dependencies and performs startup tasks.
  static Future<void> init() async {
    final auth = Get.put(AuthService(), permanent: true);
    await auth.fetchUser();
    Get.put<BaseFeedService>(FeedService(), permanent: true);
    final theme = Get.put(ThemeService(), permanent: true);
    await theme.loadThemeMode();
  }
}

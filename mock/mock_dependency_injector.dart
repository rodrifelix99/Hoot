import 'package:get/get.dart';
import 'package:hoot/services/theme_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/post_service.dart';
import 'services/mock_auth_service.dart';
import 'services/mock_feed_service.dart';
import 'services/mock_post_service.dart';
import 'package:hoot/services/auth_service.dart';

/// Registers mock dependencies for running the app without backend services.
class MockDependencyInjector {
  MockDependencyInjector._();

  /// Initializes mock services and theme settings.
  static Future<void> init() async {
    final auth = Get.put<AuthService>(MockAuthService(), permanent: true);
    final postService = MockPostService();
    await postService.load();
    Get.put<BasePostService>(postService, permanent: true);
    Get.put<BaseFeedService>(MockFeedService(postService: postService),
        permanent: true);
    final theme = Get.put(ThemeService(), permanent: true);
    await theme.loadThemeSettings();
  }
}

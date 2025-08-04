import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/subscription_manager.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/theme_service.dart';

import 'services/mock_auth_service.dart';
import 'services/mock_feed_request_service.dart';
import 'services/mock_feed_service.dart';
import 'services/mock_notification_service.dart';
import 'services/mock_post_service.dart';
import 'services/mock_subscription_service.dart';

/// Registers mock dependencies for running the app without backend services.
class MockDependencyInjector {
  MockDependencyInjector._();

  /// Initializes mock services and theme settings.
  static Future<void> init() async {
    final auth = Get.put<AuthService>(MockAuthService(), permanent: true);
    final firestore = FakeFirebaseFirestore();

    final subscriptionService = Get.put<SubscriptionService>(
      MockSubscriptionService(firestore: firestore),
      permanent: true,
    );

    Get.put<FeedRequestService>(
      MockFeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: auth,
      ),
      permanent: true,
    );

    Get.put<BaseNotificationService>(
      MockNotificationService(firestore: firestore),
      permanent: true,
    );

    Get.put(
      SubscriptionManager(
        firestore: firestore,
        subscriptionService: subscriptionService,
        feedRequestService: Get.find<FeedRequestService>(),
      ),
      permanent: true,
    );

    final postService = MockPostService();
    await postService.load();
    Get.put<BasePostService>(postService, permanent: true);
    Get.put<BaseFeedService>(
      MockFeedService(postService: postService),
      permanent: true,
    );
    final theme = Get.put(ThemeService(), permanent: true);
    await theme.loadThemeSettings();
  }
}

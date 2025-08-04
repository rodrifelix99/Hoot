import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';

/// Mock implementation of [FeedRequestService] backed by
/// [FakeFirebaseFirestore].
class MockFeedRequestService extends FeedRequestService {
  MockFeedRequestService({
    FakeFirebaseFirestore? firestore,
    SubscriptionService? subscriptionService,
    AuthService? authService,
  }) : super(
          firestore: firestore ?? FakeFirebaseFirestore(),
          subscriptionService:
              subscriptionService ?? Get.find<SubscriptionService>(),
          authService: authService ?? Get.find<AuthService>(),
        );
}

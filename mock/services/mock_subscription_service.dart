import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hoot/services/subscription_service.dart';

/// Mock implementation of [SubscriptionService] using [FakeFirebaseFirestore].
class MockSubscriptionService extends SubscriptionService {
  MockSubscriptionService({FakeFirebaseFirestore? firestore})
      : super(firestore: firestore ?? FakeFirebaseFirestore());
}

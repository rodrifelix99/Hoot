import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hoot/services/notification_service.dart';

/// Mock implementation of [BaseNotificationService] backed by
/// [FakeFirebaseFirestore].
class MockNotificationService extends NotificationService {
  MockNotificationService({FakeFirebaseFirestore? firestore})
      : super(firestore: firestore ?? FakeFirebaseFirestore());
}

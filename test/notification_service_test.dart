import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('createNotification writes document', () async {
      final firestore = FakeFirebaseFirestore();
      final service = NotificationService(firestore: firestore);

      await service.createNotification('u1', {
        'user': {'uid': 'u2'},
        'type': 0,
        'read': false,
        'createdAt': Timestamp.now(),
      });

      final snapshot = await firestore
          .collection('users')
          .doc('u1')
          .collection('notifications')
          .get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.get('type'), 0);
    });

    test('fetchNotifications returns sorted notifications', () async {
      final firestore = FakeFirebaseFirestore();
      final service = NotificationService(firestore: firestore);
      final older = Timestamp.now();
      final newer =
          Timestamp.fromDate(older.toDate().add(const Duration(seconds: 1)));

      await firestore
          .collection('users')
          .doc('u1')
          .collection('notifications')
          .add({
        'user': {'uid': 'u2'},
        'type': 0,
        'read': false,
        'createdAt': older,
      });
      await firestore
          .collection('users')
          .doc('u1')
          .collection('notifications')
          .add({
        'user': {'uid': 'u3'},
        'type': 1,
        'read': true,
        'createdAt': newer,
      });

      final result = await service.fetchNotifications('u1');

      expect(result.length, 2);
      expect(result.first.type, 1);
      expect(result.last.type, 0);
    });

    test('markAllAsRead updates unread notifications', () async {
      final firestore = FakeFirebaseFirestore();
      final service = NotificationService(firestore: firestore);

      await firestore
          .collection('users')
          .doc('u1')
          .collection('notifications')
          .add({
        'user': {'uid': 'u2'},
        'type': 0,
        'read': false,
        'createdAt': Timestamp.now(),
      });
      await firestore
          .collection('users')
          .doc('u1')
          .collection('notifications')
          .add({
        'user': {'uid': 'u3'},
        'type': 0,
        'read': false,
        'createdAt': Timestamp.now(),
      });

      await service.markAllAsRead('u1');

      final remaining = await firestore
          .collection('users')
          .doc('u1')
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      expect(remaining.docs, isEmpty);
    });
  });
}

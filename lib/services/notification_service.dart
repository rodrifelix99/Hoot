import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/models/hoot_notification.dart';

abstract class BaseNotificationService {
  Future<List<HootNotification>> fetchNotifications(String userId);
  Future<void> createNotification(String userId, Map<String, dynamic> data);
  Future<void> markAsRead(String userId, String notificationId);
  Stream<int> unreadCountStream(String userId);
  Future<void> markAllAsRead(String userId);
}

class NotificationService implements BaseNotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HootNotification>> fetchNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => HootNotification.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  @override
  Future<void> createNotification(String userId, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(data);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  @override
  Stream<int> unreadCountStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }
}

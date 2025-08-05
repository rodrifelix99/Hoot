import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/models/hoot_notification.dart';
import 'package:hoot/util/constants.dart';

class NotificationPage {
  NotificationPage({
    required this.notifications,
    this.lastDoc,
    this.hasMore = false,
  });

  final List<HootNotification> notifications;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<NotificationPage> fetchNotifications(
    String userId, {
    DocumentSnapshot? startAfter,
    int limit = kDefaultFetchLimit,
  }) async {
    var query = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final notifications = snapshot.docs
        .map((d) => HootNotification.fromJson({'id': d.id, ...d.data()}))
        .toList();

    return NotificationPage(
      notifications: notifications,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  Future<void> createNotification(String userId, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(data);
  }

  Future<void> markAsRead(String userId, String notificationId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

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

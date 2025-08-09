import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/models/hoot_notification.dart';
import 'package:hoot/services/analytics_service.dart';
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

abstract class BaseNotificationService {
  Future<NotificationPage> fetchNotifications(
    String userId, {
    DocumentSnapshot? startAfter,
    int limit = kDefaultFetchLimit,
  });
  Future<void> createNotification(String userId, Map<String, dynamic> data);
  Future<void> markAsRead(String userId, String notificationId);
  Stream<int> unreadCountStream(String userId);
  Future<void> markAllAsRead(String userId);
}

class NotificationService implements BaseNotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  @override
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

    if (_analytics != null) {
      await _analytics!.logEvent('fetch_notifications', parameters: {
        'userId': userId,
        'count': notifications.length,
      });
    }

    return NotificationPage(
      notifications: notifications,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
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
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
    if (_analytics != null) {
      await _analytics!.logEvent('mark_notification_read', parameters: {
        'userId': userId,
        'notificationId': notificationId,
      });
    }
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
    if (_analytics != null) {
      await _analytics!.logEvent('mark_all_read', parameters: {
        'userId': userId,
        'count': snapshot.docs.length,
      });
    }
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

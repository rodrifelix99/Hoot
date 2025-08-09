import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/analytics_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/constants.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore;
  final AuthService? _authService;

  SubscriptionService({FirebaseFirestore? firestore, AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService;

  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  Future<Set<String>> fetchSubscriptions(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .get();
    return snapshot.docs.map((d) => d.id).toSet();
  }

  /// Returns the [Feed]s the user with [userId] is subscribed to.
  Future<List<Feed>> fetchSubscribedFeeds(String userId) async {
    final subsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .get();
    final ids = subsSnapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return feedsSnapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> subscribe(String userId, String feedId) async {
    final userSubRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc(feedId);
    final feedSubRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('subscribers')
        .doc(userId);
    final feedRef = _firestore.collection('feeds').doc(feedId);

    await _firestore.runTransaction((txn) async {
      txn.set(userSubRef, {'createdAt': FieldValue.serverTimestamp()});
      txn.set(feedSubRef, {'createdAt': FieldValue.serverTimestamp()});
      txn.update(feedRef, {'subscriberCount': FieldValue.increment(1)});
    });
    final feedDoc = await feedRef.get();
    final ownerId = feedDoc.data()?['userId'];
    if (_analytics != null) {
      await _analytics!.logEvent('subscribe_feed', parameters: {
        'feedId': feedId,
        'subscriberId': userId,
        'ownerId': ownerId,
      });
    }
    // Subscription notifications are handled server-side by Firestore triggers.
  }

  Future<void> unsubscribe(String userId, String feedId) async {
    final userSubRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc(feedId);
    final feedSubRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('subscribers')
        .doc(userId);
    final feedRef = _firestore.collection('feeds').doc(feedId);

    await _firestore.runTransaction((txn) async {
      txn.delete(userSubRef);
      txn.delete(feedSubRef);
      txn.update(feedRef, {'subscriberCount': FieldValue.increment(-1)});
    });
    final feedDoc = await feedRef.get();
    final ownerId = feedDoc.data()?['userId'];
    if (_analytics != null) {
      await _analytics!.logEvent('unsubscribe_feed', parameters: {
        'feedId': feedId,
        'subscriberId': userId,
        'ownerId': ownerId,
      });
    }
  }

  Future<List<U>> fetchSubscribers(String feedId) async {
    final snapshot = await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('subscribers')
        .get();
    final ids = snapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];

    const chunkSize = kUserChunkSize;
    final List<U> users = [];
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
          i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      users.addAll(usersSnapshot.docs
          .map((d) => U.fromJson({'uid': d.id, ...d.data()}))
          .toList());
    }
    return users;
  }

  Future<void> removeSubscriber(String feedId, String userId) async {
    final userSubRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc(feedId);
    final feedSubRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('subscribers')
        .doc(userId);
    final feedRef = _firestore.collection('feeds').doc(feedId);

    await _firestore.runTransaction((txn) async {
      txn.delete(userSubRef);
      txn.delete(feedSubRef);
      txn.update(feedRef, {'subscriberCount': FieldValue.increment(-1)});
    });
    if (_analytics != null) {
      final actingUserId = _authService?.currentUser?.uid;
      await _analytics!.logEvent('remove_subscriber', parameters: {
        'feedId': feedId,
        'actingUserId': actingUserId,
        'targetUserId': userId,
      });
    }
  }

  Future<void> banSubscriber(String feedId, String userId) async {
    await removeSubscriber(feedId, userId);
    await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('banned')
        .doc(userId)
        .set({'createdAt': FieldValue.serverTimestamp()});
    if (_analytics != null) {
      final actingUserId = _authService?.currentUser?.uid;
      await _analytics!.logEvent('ban_subscriber', parameters: {
        'feedId': feedId,
        'actingUserId': actingUserId,
        'targetUserId': userId,
      });
    }
  }
}

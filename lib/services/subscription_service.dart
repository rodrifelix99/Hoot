import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feed.dart';
import '../models/user.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore;

  SubscriptionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
    final ownerId = feedDoc.get('userId');
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
  }

  Future<List<U>> fetchSubscribers(String feedId) async {
    final snapshot = await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('subscribers')
        .get();
    final ids = snapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];
    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return usersSnapshot.docs.map((d) => U.fromJson(d.data())).toList();
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
  }

  Future<void> banSubscriber(String feedId, String userId) async {
    await removeSubscriber(feedId, userId);
    await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('banned')
        .doc(userId)
        .set({'createdAt': FieldValue.serverTimestamp()});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> subscribe(String userId, String feedId) async {
    final userSubRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc(feedId);
    final feedRef = _firestore.collection('feeds').doc(feedId);

    await _firestore.runTransaction((txn) async {
      txn.set(userSubRef, {'createdAt': FieldValue.serverTimestamp()});
      txn.update(feedRef, {'subscriberCount': FieldValue.increment(1)});
    });
  }

  Future<void> unsubscribe(String userId, String feedId) async {
    final userSubRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .doc(feedId);
    final feedRef = _firestore.collection('feeds').doc(feedId);

    await _firestore.runTransaction((txn) async {
      txn.delete(userSubRef);
      txn.update(feedRef, {'subscriberCount': FieldValue.increment(-1)});
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'subscription_service.dart';
import '../models/user.dart';

class FeedRequestService {
  final FirebaseFirestore _firestore;
  final SubscriptionService _subscriptionService;

  FeedRequestService(
      {FirebaseFirestore? firestore, SubscriptionService? subscriptionService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>();

  Future<void> submit(String feedId, String userId) async {
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    final feedRef = _firestore.collection('feeds').doc(feedId);
    await _firestore.runTransaction((txn) async {
      txn.set(requestRef, {'createdAt': FieldValue.serverTimestamp()});
      txn.update(feedRef, {'requestCount': FieldValue.increment(1)});
    });
  }

  Future<void> accept(String feedId, String userId) async {
    await _subscriptionService.subscribe(userId, feedId);
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    final feedRef = _firestore.collection('feeds').doc(feedId);
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
      txn.update(feedRef, {'requestCount': FieldValue.increment(-1)});
    });
  }

  Future<void> reject(String feedId, String userId) async {
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    final feedRef = _firestore.collection('feeds').doc(feedId);
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
      txn.update(feedRef, {'requestCount': FieldValue.increment(-1)});
    });
  }

  Future<List<U>> fetchRequests(String feedId) async {
    final snapshot = await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .get();
    final ids = snapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];
    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return usersSnapshot.docs
        .map((d) => U.fromJson({'uid': d.id, ...d.data()}))
        .toList();
  }
}

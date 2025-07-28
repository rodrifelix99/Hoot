import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'subscription_service.dart';
import '../models/user.dart';
import 'auth_service.dart';

class FeedRequestService {
  final FirebaseFirestore _firestore;
  final SubscriptionService _subscriptionService;
  final AuthService _authService;

  FeedRequestService(
      {FirebaseFirestore? firestore,
      SubscriptionService? subscriptionService,
      AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>(),
        _authService = authService ?? Get.find<AuthService>();

  Future<void> submit(String feedId, String userId) async {
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    await _firestore.runTransaction((txn) async {
      txn.set(requestRef, {'createdAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> accept(String feedId, String userId) async {
    await _subscriptionService.subscribe(userId, feedId);
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
    });
  }

  Future<void> reject(String feedId, String userId) async {
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
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

  /// Returns the number of pending requests for the current user's feeds.
  Future<int> pendingRequestCount() async {
    final user = _authService.currentUser;
    if (user == null) return 0;
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: user.uid)
        .get();
    var total = 0;
    for (final doc in feedsSnapshot.docs) {
      final requests = await _firestore
          .collection('feeds')
          .doc(doc.id)
          .collection('requests')
          .get();
      total += requests.docs.length;
    }
    return total;
  }
}

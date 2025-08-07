import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed_join_request.dart';
import 'dart:math' as math;
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/constants.dart';

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
      final userData = _authService.currentUser?.toCache() ?? {};
      txn.set(requestRef, {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> accept(String feedId, String userId) async {
    await _subscriptionService.subscribe(userId, feedId);
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    final feedDoc = await _firestore.collection('feeds').doc(feedId).get();
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
    });
    final userData = _authService.currentUser?.toCache() ?? {};
    final feedData = {
      'id': feedDoc.id,
      'title': feedDoc.data()?['title'],
    };
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'user': userData,
      'feed': feedData,
      'type': 7,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reject(String feedId, String userId) async {
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    final feedDoc = await _firestore.collection('feeds').doc(feedId).get();
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
    });
    final userData = _authService.currentUser?.toCache() ?? {};
    final feedData = {
      'id': feedDoc.id,
      'title': feedDoc.data()?['title'],
    };
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'user': userData,
      'feed': feedData,
      'type': 8,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancel(String feedId, String userId) async {
    final requestRef = _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId);
    await _firestore.runTransaction((txn) async {
      txn.delete(requestRef);
    });
  }

  /// Returns true if [userId] has a pending request to join the feed [feedId].
  Future<bool> exists(String feedId, String userId) async {
    final doc = await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .doc(userId)
        .get();
    return doc.exists;
  }

  Future<List<FeedJoinRequest>> fetchRequests(String feedId) async {
    final snapshot = await _firestore
        .collection('feeds')
        .doc(feedId)
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .get();
    final ids = snapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];

    const chunkSize = kUserChunkSize;
    final Map<String, U> users = {};
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, math.min(i + chunkSize, ids.length));
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in usersSnapshot.docs) {
        users[doc.id] = U.fromJson({'uid': doc.id, ...doc.data()});
      }
    }

    return snapshot.docs
        .where((d) => users.containsKey(d.id))
        .map((d) => FeedJoinRequest(
              feedId: feedId,
              user: users[d.id]!,
              createdAt: (d.data()['createdAt'] as Timestamp).toDate(),
            ))
        .toList();
  }

  /// Returns all pending join requests for feeds owned by the current user.
  Future<List<FeedJoinRequest>> fetchRequestsForMyFeeds() async {
    final user = _authService.currentUser;
    if (user == null) return [];
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: user.uid)
        .get();
    final List<FeedJoinRequest> all = [];
    for (final doc in feedsSnapshot.docs) {
      final requests = await fetchRequests(doc.id);
      all.addAll(requests);
    }
    return all;
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import 'feed_request_service.dart';
import 'subscription_service.dart';

/// Possible outcomes when toggling a feed subscription.
enum SubscriptionResult { subscribed, unsubscribed, requested }

/// Service handling subscription and join request logic.
class SubscriptionManager {
  final FirebaseFirestore _firestore;
  final SubscriptionService _subscriptionService;
  final FeedRequestService _feedRequestService;

  SubscriptionManager({
    FirebaseFirestore? firestore,
    SubscriptionService? subscriptionService,
    FeedRequestService? feedRequestService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>(),
        _feedRequestService =
            feedRequestService ?? Get.find<FeedRequestService>();

  /// Toggles the current subscription state for [feedId] and [user].
  ///
  /// Returns a [SubscriptionResult] describing the new state.
  Future<SubscriptionResult> toggle(String feedId, U user) async {
    final subDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .doc(feedId)
        .get();

    if (subDoc.exists) {
      await _subscriptionService.unsubscribe(user.uid, feedId);
      return SubscriptionResult.unsubscribed;
    }

    final feedDoc = await _firestore.collection('feeds').doc(feedId).get();
    final isPrivate = feedDoc.data()?['private'] == true;

    if (isPrivate) {
      final hasRequest = await _feedRequestService.exists(feedId, user.uid);
      if (hasRequest) {
        await _feedRequestService.cancel(feedId, user.uid);
        return SubscriptionResult.unsubscribed;
      }
      await _feedRequestService.submit(feedId, user.uid);
      return SubscriptionResult.requested;
    }

    await _subscriptionService.subscribe(user.uid, feedId);
    return SubscriptionResult.subscribed;
  }
}

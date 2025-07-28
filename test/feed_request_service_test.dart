import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';

void main() {
  group('FeedRequestService', () {
    test('submit creates request and increments count', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(firestore: firestore),
      );
      await firestore.collection('feeds').doc('f1').set({'requestCount': 0});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      await service.submit('f1', 'u1');

      final req = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .get();
      final feed = await firestore.collection('feeds').doc('f1').get();

      expect(req.exists, isTrue);
      expect(feed.get('requestCount'), 1);
    });

    test('accept subscribes user and removes request', () async {
      final firestore = FakeFirebaseFirestore();
      final subscriptionService = SubscriptionService(firestore: firestore);
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
      );
      await firestore.collection('feeds').doc('f1').set({
        'requestCount': 1,
        'subscriberCount': 0,
      });
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});

      await service.accept('f1', 'u1');

      final req = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .get();
      final feed = await firestore.collection('feeds').doc('f1').get();
      final userSub = await firestore
          .collection('users')
          .doc('u1')
          .collection('subscriptions')
          .doc('f1')
          .get();
      final feedSub = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('subscribers')
          .doc('u1')
          .get();

      expect(req.exists, isFalse);
      expect(feed.get('requestCount'), 0);
      expect(userSub.exists, isTrue);
      expect(feedSub.exists, isTrue);
    });

    test('reject removes request only', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(firestore: firestore),
      );
      await firestore.collection('feeds').doc('f1').set({'requestCount': 1});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});

      await service.reject('f1', 'u1');

      final req = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .get();
      final feed = await firestore.collection('feeds').doc('f1').get();

      expect(req.exists, isFalse);
      expect(feed.get('requestCount'), 0);
    });
  });
}

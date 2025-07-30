import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/services/subscription_service.dart';

void main() {
  group('SubscriptionService', () {
    test('removeSubscriber deletes docs and decrements count', () async {
      final firestore = FakeFirebaseFirestore();
      final service = SubscriptionService(
        firestore: firestore,
      );
      await firestore.collection('feeds').doc('f1').set({'subscriberCount': 1});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      await firestore
          .collection('users')
          .doc('u1')
          .collection('subscriptions')
          .doc('f1')
          .set({'createdAt': Timestamp.now()});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('subscribers')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});

      await service.removeSubscriber('f1', 'u1');

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
      final feed = await firestore.collection('feeds').doc('f1').get();

      expect(userSub.exists, isFalse);
      expect(feedSub.exists, isFalse);
      expect(feed.get('subscriberCount'), 0);
    });

    test('banSubscriber moves user to banned list', () async {
      final firestore = FakeFirebaseFirestore();
      final service = SubscriptionService(
        firestore: firestore,
      );
      await firestore.collection('feeds').doc('f1').set({'subscriberCount': 1});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      await firestore
          .collection('users')
          .doc('u1')
          .collection('subscriptions')
          .doc('f1')
          .set({'createdAt': Timestamp.now()});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('subscribers')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});

      await service.banSubscriber('f1', 'u1');

      final banned = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('banned')
          .doc('u1')
          .get();
      final feed = await firestore.collection('feeds').doc('f1').get();

      expect(banned.exists, isTrue);
      expect(feed.get('subscriberCount'), 0);
    });

    test('fetchSubscribers returns all users even when more than 10', () async {
      final firestore = FakeFirebaseFirestore();
      final service = SubscriptionService(
        firestore: firestore,
      );
      await firestore.collection('feeds').doc('f1').set({});
      for (var i = 0; i < 11; i++) {
        await firestore.collection('users').doc('u\$i').set({'uid': 'u\$i'});
        await firestore
            .collection('feeds')
            .doc('f1')
            .collection('subscribers')
            .doc('u\$i')
            .set({'createdAt': Timestamp.now()});
      }

      final result = await service.fetchSubscribers('f1');

      expect(result.length, 11);
      expect(result.first.uid, 'u0');
    });
  });
}

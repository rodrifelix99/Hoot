import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/user.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U _user;
  FakeAuthService(this._user);

  @override
  U? get currentUser => _user;

  @override
  Future<U?> fetchUser() async => _user;

  @override
  Future<U?> fetchUserById(String uid) async => _user;

  @override
  Future<U?> fetchUserByUsername(String username) async => _user;

  @override
  Future<List<U>> searchUsers(String query, {int limit = 5}) async => [];

  @override
  Future<void> signOut() async {}

  @override
  Future<UserCredential> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserCredential> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> deleteAccount() async {}
}

void main() {
  group('FeedRequestService', () {
    test('submit creates request document', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(
          firestore: firestore,
          notificationService: NotificationService(firestore: firestore),
        ),
        authService: FakeAuthService(U(uid: 'owner')),
      );
      await firestore.collection('feeds').doc('f1').set({});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      await service.submit('f1', 'u1');

      final req = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .get();
      expect(req.exists, isTrue);
    });

    test('accept subscribes user and removes request', () async {
      final firestore = FakeFirebaseFirestore();
      final subscriptionService = SubscriptionService(
        firestore: firestore,
        notificationService: NotificationService(firestore: firestore),
      );
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: FakeAuthService(U(uid: 'owner')),
      );
      await firestore.collection('feeds').doc('f1').set({
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
      expect(userSub.exists, isTrue);
      expect(feedSub.exists, isTrue);
    });

    test('reject removes request only', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(
          firestore: firestore,
          notificationService: NotificationService(firestore: firestore),
        ),
        authService: FakeAuthService(U(uid: 'owner')),
      );
      await firestore.collection('feeds').doc('f1').set({});
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

      expect(req.exists, isFalse);
    });

    test('pendingRequestCount returns total for user feeds', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({'userId': 'owner'});
      await firestore.collection('feeds').doc('f2').set({'userId': 'owner'});
      await firestore.collection('users').doc('r1').set({'uid': 'r1'});
      await firestore.collection('users').doc('r2').set({'uid': 'r2'});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('r1')
          .set({'createdAt': Timestamp.now()});
      await firestore
          .collection('feeds')
          .doc('f2')
          .collection('requests')
          .doc('r2')
          .set({'createdAt': Timestamp.now()});

      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(
          firestore: firestore,
          notificationService: NotificationService(firestore: firestore),
        ),
        authService: FakeAuthService(U(uid: 'owner')),
      );

      final count = await service.pendingRequestCount();
      expect(count, 2);
    });
  });
}

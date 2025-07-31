import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/services/subscription_manager.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/models/user.dart';

import 'package:firebase_auth/firebase_auth.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U _user;
  FakeAuthService(this._user);

  @override
  U? get currentUser => _user;

  @override
  Stream<U?> get currentUserStream => Stream.value(_user);

  @override
  Rxn<U> get currentUserRx => Rxn<U>()..value = _user;

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

  @override
  Future<U?> refreshUser() async => _user;

  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}
}

void main() {
  group('SubscriptionManager.toggle', () {
    test('unsubscribes when already subscribed', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({
        'userId': 'owner',
        'subscriberCount': 1,
      });
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

      final subscriptionService = SubscriptionService(firestore: firestore);
      final feedRequestService = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: FakeAuthService(U(uid: 'owner')),
      );
      final manager = SubscriptionManager(
        firestore: firestore,
        subscriptionService: subscriptionService,
        feedRequestService: feedRequestService,
      );

      final result = await manager.toggle('f1', U(uid: 'u1'));

      expect(result, SubscriptionResult.unsubscribed);
      final userSub = await firestore
          .collection('users')
          .doc('u1')
          .collection('subscriptions')
          .doc('f1')
          .get();
      expect(userSub.exists, isFalse);
    });

    test('subscribes when not subscribed and feed is public', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({
        'userId': 'owner',
        'private': false,
        'subscriberCount': 0,
      });
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      final subscriptionService = SubscriptionService(firestore: firestore);
      final feedRequestService = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: FakeAuthService(U(uid: 'owner')),
      );
      final manager = SubscriptionManager(
        firestore: firestore,
        subscriptionService: subscriptionService,
        feedRequestService: feedRequestService,
      );

      final result = await manager.toggle('f1', U(uid: 'u1'));

      expect(result, SubscriptionResult.subscribed);
      final userSub = await firestore
          .collection('users')
          .doc('u1')
          .collection('subscriptions')
          .doc('f1')
          .get();
      expect(userSub.exists, isTrue);
    });

    test('requests when feed is private', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({
        'userId': 'owner',
        'private': true,
      });
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      final subscriptionService = SubscriptionService(firestore: firestore);
      final feedRequestService = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: FakeAuthService(U(uid: 'owner')),
      );
      final manager = SubscriptionManager(
        firestore: firestore,
        subscriptionService: subscriptionService,
        feedRequestService: feedRequestService,
      );

      final result = await manager.toggle('f1', U(uid: 'u1'));

      expect(result, SubscriptionResult.requested);
      final request = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .get();
      expect(request.exists, isTrue);
    });

    test('cancels request when already requested', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({
        'userId': 'owner',
        'private': true,
      });
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});

      final subscriptionService = SubscriptionService(firestore: firestore);
      final feedRequestService = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: FakeAuthService(U(uid: 'owner')),
      );
      final manager = SubscriptionManager(
        firestore: firestore,
        subscriptionService: subscriptionService,
        feedRequestService: feedRequestService,
      );

      final result = await manager.toggle('f1', U(uid: 'u1'));

      expect(result, SubscriptionResult.unsubscribed);
      final request = await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .get();
      expect(request.exists, isFalse);
    });
  });
}

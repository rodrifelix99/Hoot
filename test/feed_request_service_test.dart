import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/user.dart';

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
  group('FeedRequestService', () {
    test('submit creates request document', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(
          firestore: firestore,
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
      expect(req.data()!.containsKey('createdAt'), isTrue);
    });

    test('accept subscribes user and removes request', () async {
      final firestore = FakeFirebaseFirestore();
      final subscriptionService = SubscriptionService(
        firestore: firestore,
      );
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: subscriptionService,
        authService: FakeAuthService(U(uid: 'owner')),
      );
      await firestore.collection('feeds').doc('f1').set({
        'subscriberCount': 0,
        'userId': 'owner',
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

    test('exists returns true when request present', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(
          firestore: firestore,
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

      final result = await service.exists('f1', 'u1');
      expect(result, isTrue);
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
        ),
        authService: FakeAuthService(U(uid: 'owner')),
      );

      final count = await service.pendingRequestCount();
      expect(count, 2);
    });

    test('fetchRequests returns ordered join requests', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(
          firestore: firestore,
        ),
        authService: FakeAuthService(U(uid: 'owner')),
      );
      await firestore.collection('feeds').doc('f1').set({});
      for (var i = 0; i < 11; i++) {
        await firestore.collection('users').doc('u$i').set({'uid': 'u$i'});
        await firestore
            .collection('feeds')
            .doc('f1')
            .collection('requests')
            .doc('u$i')
            .set({'createdAt': Timestamp.fromMillisecondsSinceEpoch(i * 1000)});
      }

      final result = await service.fetchRequests('f1');

      expect(result.length, 11);
      expect(result.first.feedId, 'f1');
      expect(result.first.user.uid, 'u10');
      expect(result.last.user.uid, 'u0');
      expect(result.first.createdAt.isAfter(result.last.createdAt), isTrue);
    });

    test('fetchRequestsForMyFeeds aggregates requests', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({'userId': 'owner'});
      await firestore.collection('feeds').doc('f2').set({'userId': 'owner'});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      await firestore.collection('users').doc('u2').set({'uid': 'u2'});
      await firestore
          .collection('feeds')
          .doc('f1')
          .collection('requests')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});
      await firestore
          .collection('feeds')
          .doc('f2')
          .collection('requests')
          .doc('u2')
          .set({'createdAt': Timestamp.now()});

      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(firestore: firestore),
        authService: FakeAuthService(U(uid: 'owner')),
      );

      final result = await service.fetchRequestsForMyFeeds();

      expect(result.length, 2);
      expect(result.map((r) => r.feedId).toSet(), {'f1', 'f2'});
    });

    test('fetchRequestsForMyFeeds returns request after submit', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({'userId': 'owner'});
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      final service = FeedRequestService(
        firestore: firestore,
        subscriptionService: SubscriptionService(firestore: firestore),
        authService: FakeAuthService(U(uid: 'owner')),
      );

      await service.submit('f1', 'u1');

      final result = await service.fetchRequestsForMyFeeds();

      expect(result.length, 1);
      expect(result.first.feedId, 'f1');
      expect(result.first.user.uid, 'u1');
      expect(result.first.createdAt, isNotNull);
    });
  });
}

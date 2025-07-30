import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U? _user;
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

  @override
  Future<U?> refreshUser() async => _user;
  
  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}
}

void main() {
  group('FeedService.fetchFeedPosts', () {
    test('allows owner or subscriber to access posts', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({'userId': 'owner'});
      await firestore.collection('users').doc('owner').set({'uid': 'owner'});
      await firestore.collection('users').doc('sub').set({'uid': 'sub'});
      await firestore
          .collection('users')
          .doc('sub')
          .collection('subscriptions')
          .doc('f1')
          .set({'createdAt': Timestamp.now()});
      await firestore
          .collection('posts')
          .doc('p1')
          .set({'feedId': 'f1', 'createdAt': Timestamp.now()});

      final ownerService = FeedService(
          firestore: firestore, authService: FakeAuthService(U(uid: 'owner')));
      final ownerPage = await ownerService.fetchFeedPosts('f1');
      expect(ownerPage.posts, isNotEmpty);

      final subService = FeedService(
          firestore: firestore, authService: FakeAuthService(U(uid: 'sub')));
      final subPage = await subService.fetchFeedPosts('f1');
      expect(subPage.posts, isNotEmpty);
    });

    test('returns empty page when user not subscribed', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({'userId': 'owner'});
      await firestore.collection('users').doc('other').set({'uid': 'other'});
      await firestore
          .collection('posts')
          .doc('p1')
          .set({'feedId': 'f1', 'createdAt': Timestamp.now()});

      final service = FeedService(
          firestore: firestore, authService: FakeAuthService(U(uid: 'other')));
      final page = await service.fetchFeedPosts('f1');
      expect(page.posts, isEmpty);
    });
  });
}

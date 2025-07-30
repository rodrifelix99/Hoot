import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:hoot/services/post_service.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  group('PostService', () {
    test('toggleLike increments and decrements', () async {
      final firestore = FakeFirebaseFirestore();
      final service = PostService(
        firestore: firestore,
      );
      await firestore.collection('posts').doc('p1').set({'likes': 0});

      await service.toggleLike('p1', 'u1', true);
      var post = await firestore.collection('posts').doc('p1').get();
      expect(post.get('likes'), 1);
      expect(
          (await firestore
                  .collection('posts')
                  .doc('p1')
                  .collection('likes')
                  .doc('u1')
                  .get())
              .exists,
          isTrue);

      await service.toggleLike('p1', 'u1', false);
      post = await firestore.collection('posts').doc('p1').get();
      expect(post.get('likes'), 0);
      expect(
          (await firestore
                  .collection('posts')
                  .doc('p1')
                  .collection('likes')
                  .doc('u1')
                  .get())
              .exists,
          isFalse);
    });

    test('toggleLike does not duplicate likes', () async {
      final firestore = FakeFirebaseFirestore();
      final service = PostService(
        firestore: firestore,
      );
      await firestore.collection('posts').doc('p1').set({'likes': 0});

      await service.toggleLike('p1', 'u1', true);
      // Attempt to like again when already liked
      await service.toggleLike('p1', 'u1', true);

      final post = await firestore.collection('posts').doc('p1').get();
      expect(post.get('likes'), 1);
      expect(
          (await firestore
                  .collection('posts')
                  .doc('p1')
                  .collection('likes')
                  .doc('u1')
                  .get())
              .exists,
          isTrue);
    });

    test('reFeed creates new post', () async {
      final firestore = FakeFirebaseFirestore();
      final service = PostService(
        firestore: firestore,
      );
      await firestore
          .collection('posts')
          .doc('orig')
          .set({'text': 'Hello', 'reFeeds': 0});
      final original = Post(id: 'orig', text: 'Hello');
      final feed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 'feed',
          description: 'd',
          color: Colors.blue);
      final user = U(uid: 'u1');

      final newId = await service.reFeed(
          original: original, targetFeed: feed, user: user);

      final newDoc = await firestore.collection('posts').doc(newId).get();
      expect(newDoc.exists, isTrue);
      expect(newDoc.get('reFeeded'), true);
      expect(newDoc.get('reFeededFrom')['id'], 'orig');
      expect(
          (await firestore.collection('posts').doc('orig').get())
              .get('reFeeds'),
          1);
    });

    test('fetchPost returns post when found', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('posts').doc('p1').set({'text': 'hello'});
      final service = PostService(firestore: firestore);

      final post = await service.fetchPost('p1');

      expect(post, isNotNull);
      expect(post!.id, 'p1');
      expect(post.text, 'hello');
    });

    test('fetchPost marks post as liked when like exists', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('posts').doc('p1').set({'text': 'hello'});
      await firestore
          .collection('posts')
          .doc('p1')
          .collection('likes')
          .doc('u1')
          .set({'createdAt': Timestamp.now()});
      final service = PostService(
        firestore: firestore,
        authService: FakeAuthService(U(uid: 'u1')),
      );

      final post = await service.fetchPost('p1');

      expect(post?.liked, isTrue);
    });

    test('fetchPost returns null when missing', () async {
      final firestore = FakeFirebaseFirestore();
      final service = PostService(firestore: firestore);

      final post = await service.fetchPost('missing');

      expect(post, isNull);
    });
  });
}

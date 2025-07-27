import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/services/post_service.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:flutter/material.dart';

void main() {
  group('PostService', () {
    test('toggleLike increments and decrements', () async {
      final firestore = FakeFirebaseFirestore();
      final service = PostService(firestore: firestore);
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

    test('reFeed creates new post', () async {
      final firestore = FakeFirebaseFirestore();
      final service = PostService(firestore: firestore);
      await firestore.collection('posts').doc('orig').set({'text': 'Hello', 'reFeeds': 0});
      final original = Post(id: 'orig', text: 'Hello');
      final feed = Feed(id: 'f1', userId: 'u1', title: 'feed', description: 'd', color: Colors.blue);
      final user = U(uid: 'u1');

      final newId = await service.reFeed(original: original, targetFeed: feed, user: user);

      final newDoc = await firestore.collection('posts').doc(newId).get();
      expect(newDoc.exists, isTrue);
      expect(newDoc.get('reFeeded'), true);
      expect(newDoc.get('reFeededFrom')['id'], 'orig');
      expect((await firestore.collection('posts').doc('orig').get()).get('reFeeds'), 1);
    });
  });
}

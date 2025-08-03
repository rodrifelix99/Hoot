import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hoot/services/comment_service.dart';

void main() {
  group('CommentService', () {
    test('deleteComment removes comment and decrements count', () async {
      final firestore = FakeFirebaseFirestore();
      final service = CommentService(firestore: firestore);

      await firestore.collection('posts').doc('p1').set({'comments': 1});
      await firestore
          .collection('posts')
          .doc('p1')
          .collection('comments')
          .doc('c1')
          .set({'text': 'hi'});

      await service.deleteComment('p1', 'c1');

      final commentSnap = await firestore
          .collection('posts')
          .doc('p1')
          .collection('comments')
          .doc('c1')
          .get();
      expect(commentSnap.exists, isFalse);

      final postSnap = await firestore.collection('posts').doc('p1').get();
      expect(postSnap.get('comments'), 0);
    });
  });
}

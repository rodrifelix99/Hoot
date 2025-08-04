import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hoot/services/feedback_service.dart';
import 'package:hoot/models/feedback.dart' as fb;

void main() {
  group('FeedbackService.fetchFeedbacks', () {
    test('returns feedback list from firestore', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feedback').doc('f1').set({
        'message': 'msg1',
        'screenshot': 'url1',
        'userId': 'u1',
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      });
      final service = FeedbackService(firestore: firestore);
      final List<fb.Feedback> result = await service.fetchFeedbacks();
      expect(result.length, 1);
      expect(result.first.message, 'msg1');
      expect(result.first.screenshot, 'url1');
      expect(result.first.userId, 'u1');
    });
  });
}

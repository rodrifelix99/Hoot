import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';

import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:hoot/models/feed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreatePostController', () {
    testWidgets('publish fails when no feed is selected', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final controller =
          CreatePostController(firestore: firestore, userId: 'u1');
      controller.textController.text = 'Hello';
      expect(await controller.publish(), isFalse);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('publish fails when text exceeds 280 chars', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final controller =
          CreatePostController(firestore: firestore, userId: 'u1');
      controller.textController.text = 'a' * 281;
      controller.selectedFeed.value =
          Feed(id: 'f1', title: 't', description: 'd');
      expect(await controller.publish(), isFalse);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('successful publish writes document', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final controller =
          CreatePostController(firestore: firestore, userId: 'u1');
      controller.selectedFeed.value =
          Feed(id: 'f1', title: 't', description: 'd');
      controller.textController.text = 'Hi';
      final result = await controller.publish();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      final posts = await firestore.collection('posts').get();
      expect(posts.docs.length, 1);
      expect(posts.docs.first.get('text'), 'Hi');
    });
  });
}

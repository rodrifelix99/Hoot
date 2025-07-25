import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';

import 'package:hoot/pages/create_feed/controllers/create_feed_controller.dart';
import 'package:hoot/util/enums/feed_types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('successful create writes document', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final controller =
        CreateFeedController(firestore: firestore, userId: 'u1');
    controller.titleController.text = 'My Feed';
    controller.descriptionController.text = 'Desc';
    controller.selectedType.value = FeedType.music;

    final result = await controller.createFeed();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    final feeds = await firestore.collection('feeds').get();
    expect(feeds.docs.length, 1);
    expect(feeds.docs.first.get('title'), 'My Feed');
    expect(feeds.docs.first.get('type'), 'music');
  });
}

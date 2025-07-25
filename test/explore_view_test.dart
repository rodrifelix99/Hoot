import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:hoot/pages/explore/controllers/explore_controller.dart';
import 'package:hoot/pages/explore/views/explore_view.dart';
import 'package:hoot/util/translations/app_translations.dart';

void main() {
  testWidgets('ExploreView shows search suggestions', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('u1').set({
      'uid': 'u1',
      'displayName': 'Tester',
      'username': 'tester',
    });
    await firestore.collection('feeds').doc('f1').set({
      'title': 'test feed',
      'description': 'D',
      'color': '0',
      'type': 'music',
      'userId': 'u1',
      'subscriberCount': 1,
      'createdAt': DateTime.now(),
    });
    await firestore.collection('feed_types').doc('music').set({'count': 1});

    Get.put(ExploreController(firestore: firestore));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const Scaffold(body: ExploreView()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final controller = Get.find<ExploreController>();
    expect(controller.userSuggestions.length, 1);
    expect(controller.feedSuggestions.length, 1);

    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('test feed'), findsWidgets);

    Get.reset();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/feed/controllers/feed_controller.dart';
import 'package:hoot/pages/feed/views/feed_view.dart';
import 'package:hoot/services/feed_service.dart';

class FakeFeedService implements BaseFeedService {
  @override
  Future<List<Post>> fetchSubscribedPosts() async {
    return [
      Post(
        id: '1',
        text: 'Hello world',
        user: U(uid: 'u1', name: 'Tester'),
        media: [],
      ),
    ];
  }
}

void main() {
  testWidgets('FeedView shows posts from controller', (tester) async {
    final controller = FeedController(service: FakeFeedService());
    Get.put<FeedController>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: FeedView()),
      ),
    );

    // Wait for posts to load
    await tester.pumpAndSettle();

    expect(find.text('Hello world'), findsOneWidget);
    expect(find.text('Tester'), findsOneWidget);
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/feed/controllers/feed_controller.dart';
import 'package:hoot/pages/feed/views/feed_view.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeFeedService implements BaseFeedService {
  @override
  Future<PostPage> fetchSubscribedPosts({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    return PostPage(posts: [
      Post(
        id: '1',
        text: 'Hello world',
        user: U(uid: 'u1', name: 'Tester'),
        media: [],
      ),
    ]);
  }

  @override
  Future<PostPage> fetchFeedPosts(String feedId,
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('FeedView shows posts from controller', (tester) async {
    final controller = FeedController(service: FakeFeedService());
    Get.put<FeedController>(controller);

    await tester.pumpWidget(
      const GetCupertinoApp(
        home: CupertinoPageScaffold(child: FeedView()),
      ),
    );

    // Wait for posts to load
    await tester.pumpAndSettle();

    expect(find.text('Hello world'), findsOneWidget);
    expect(find.text('Tester'), findsOneWidget);
  });
}

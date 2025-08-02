import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/services/feed_service.dart';
import 'mock_post_service.dart';

/// Mock implementation of [BaseFeedService] returning posts from memory.
class MockFeedService implements BaseFeedService {
  MockFeedService({required this.postService});

  final MockPostService postService;

  @override
  Future<PostPage> fetchSubscribedPosts(
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    final posts = postService.posts.take(limit).toList();
    return PostPage(posts: posts, hasMore: postService.posts.length > limit);
  }

  @override
  Future<PostPage> fetchFeedPosts(String feedId,
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    final posts =
        postService.posts.where((p) => p.feedId == feedId).take(limit).toList();
    return PostPage(posts: posts, hasMore: false);
  }
}

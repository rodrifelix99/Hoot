import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/post.dart';
import 'auth_service.dart';

/// Page of posts along with pagination data.
class PostPage {
  PostPage({required this.posts, this.lastDoc, this.hasMore = false});

  final List<Post> posts;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
}

/// Service retrieving posts from feeds the current user is subscribed to.
abstract class BaseFeedService {
  Future<PostPage> fetchSubscribedPosts({
    DocumentSnapshot? startAfter,
    int limit = 10,
  });

  Future<PostPage> fetchFeedPosts(
    String feedId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  });
}

/// Default implementation retrieving posts from feeds the current user is subscribed to.
class FeedService implements BaseFeedService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  FeedService({FirebaseFirestore? firestore, AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? Get.find<AuthService>();

  /// Returns the latest posts from the user's subscriptions ordered by creation.
  @override
  Future<PostPage> fetchSubscribedPosts({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return PostPage(posts: [], hasMore: false);

    final subsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .get();

    final feedIds = subsSnapshot.docs.map((d) => d.id).toList();
    if (feedIds.isEmpty) return PostPage(posts: [], hasMore: false);
    var query = _firestore
        .collection('posts')
        .where('feedId', whereIn: feedIds)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final postsSnapshot = await query.get();

    final posts = postsSnapshot.docs
        .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
        .toList();

    return PostPage(
      posts: posts,
      lastDoc: postsSnapshot.docs.isNotEmpty ? postsSnapshot.docs.last : null,
      hasMore: postsSnapshot.docs.length == limit,
    );
  }

  @override
  Future<PostPage> fetchFeedPosts(
    String feedId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    var query = _firestore
        .collection('posts')
        .where('feedId', isEqualTo: feedId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final posts = snapshot.docs
        .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
        .toList();

    return PostPage(
      posts: posts,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }
}

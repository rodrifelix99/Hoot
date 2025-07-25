import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/post.dart';
import 'auth_service.dart';

/// Service retrieving posts from feeds the current user is subscribed to.
abstract class BaseFeedService {
  Future<List<Post>> fetchSubscribedPosts();
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
  Future<List<Post>> fetchSubscribedPosts() async {
    final user = _authService.currentUser;
    if (user == null) return [];

    final subsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscriptions')
        .get();

    final feedIds = subsSnapshot.docs.map((d) => d.id).toList();
    if (feedIds.isEmpty) return [];

    final postsSnapshot = await _firestore
        .collection('posts')
        .where('feedId', whereIn: feedIds)
        .orderBy('createdAt', descending: true)
        .get();

    return postsSnapshot.docs
        .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/analytics_service.dart';
import 'package:get/get.dart';
import 'package:hoot/util/constants.dart';

class PostPage {
  PostPage({required this.posts, this.lastDoc, this.hasMore = false});

  final List<Post> posts;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
}

/// Base interface for creating posts in Firestore.
abstract class BasePostService {
  /// Generates a new unique identifier for a post document.
  String newPostId();

  /// Creates a post document with optional [id] and [challengeId].
  Future<void> createPost(Map<String, dynamic> data,
      {String? id, String? challengeId});

  /// Toggles like state for [postId] by [userId].
  Future<void> toggleLike(String postId, String userId, bool like);

  /// Fetches a post document by [id]. Returns null if not found.
  Future<Post?> fetchPost(String id);

  /// Fetches posts participating in a challenge identified by [challengeId].
  Future<PostPage> fetchChallengePosts(
    String challengeId, {
    DocumentSnapshot? startAfter,
    int limit = kDefaultFetchLimit,
  });

  /// Creates a reFeed of [original] into [targetFeed] by [user].
  /// Returns the new post id.
  Future<String> reFeed({
    required Post original,
    required Feed targetFeed,
    required U user,
  });

  /// Deletes a post document by [id].
  Future<void> deletePost(String id);
}

/// Default implementation writing to the `posts` collection.
class PostService implements BasePostService {
  final FirebaseFirestore _firestore;
  final AuthService? _authService;
  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  PostService({FirebaseFirestore? firestore, AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService;

  @override
  String newPostId() => _firestore.collection('posts').doc().id;

  @override
  Future<void> createPost(Map<String, dynamic> data,
      {String? id, String? challengeId}) async {
    if (challengeId != null) {
      data['challengeId'] = challengeId;
    }
    if (id != null) {
      await _firestore.collection('posts').doc(id).set(data);
    } else {
      final doc = await _firestore.collection('posts').add(data);
      id = doc.id;
    }
    if (_analytics != null) {
      final media = (data['images'] ?? data['gifs']) as List<dynamic>?;
      await _analytics!.logEvent('create_post', parameters: {
        'postId': id,
        'feedId': data['feedId'],
        'mediaCount': media?.length ?? 0,
        'hasMedia': media != null && media.isNotEmpty,
        'challengeId': challengeId,
        'challenge': challengeId != null,
      });
    }
    // Mentions are now handled server-side by a Firestore trigger.
  }

  @override
  Future<void> toggleLike(String postId, String userId, bool like) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);
    var changed = false;
    await _firestore.runTransaction((txn) async {
      final likeSnap = await txn.get(likeRef);
      final currentlyLiked = likeSnap.exists;
      if (like && !currentlyLiked) {
        txn.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        txn.update(postRef, {'likes': FieldValue.increment(1)});
        changed = true;
      } else if (!like && currentlyLiked) {
        txn.delete(likeRef);
        txn.update(postRef, {'likes': FieldValue.increment(-1)});
        changed = true;
      }
    });
    if (changed && _analytics != null) {
      final snap = await postRef.get();
      final likeCount = snap.data()?['likes'] ?? 0;
      await _analytics!
          .logEvent(like ? 'like_post' : 'unlike_post', parameters: {
        'postId': postId,
        'userId': userId,
        'likeCount': likeCount,
      });
    }
    // Like notifications are handled server-side by a Firestore trigger.
  }

  @override
  Future<Post?> fetchPost(String id) async {
    final postRef = _firestore.collection('posts').doc(id);
    final doc = await postRef.get();
    if (!doc.exists) return null;
    await postRef.update({'views': FieldValue.increment(1)});
    if (_analytics != null) {
      await _analytics!.logEvent('view_post', parameters: {
        'postId': id,
        'userId': _authService?.currentUser?.uid,
      });
    }
    final data = {'id': doc.id, ...doc.data()!};
    if (_authService?.currentUser != null) {
      final uid = _authService!.currentUser!.uid;
      final likeDoc = await _firestore
          .collection('posts')
          .doc(id)
          .collection('likes')
          .doc(uid)
          .get();
      data['liked'] = likeDoc.exists;
      final reFeedDoc = await _firestore
          .collection('posts')
          .doc(id)
          .collection('reFeeds')
          .doc(uid)
          .get();
      data['reFeededByMe'] = reFeedDoc.exists;
    }
    return Post.fromJson(data);
  }

  @override
  Future<PostPage> fetchChallengePosts(
    String challengeId, {
    DocumentSnapshot? startAfter,
    int limit = kDefaultFetchLimit,
  }) async {
    var query = _firestore
        .collection('posts')
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final posts = snapshot.docs
        .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
        .toList();

    final user = _authService?.currentUser;
    if (user != null) {
      for (final post in posts) {
        final likeDoc = await _firestore
            .collection('posts')
            .doc(post.id)
            .collection('likes')
            .doc(user.uid)
            .get();
        post.liked = likeDoc.exists;
        final reFeedDoc = await _firestore
            .collection('posts')
            .doc(post.id)
            .collection('reFeeds')
            .doc(user.uid)
            .get();
        post.reFeededByMe = reFeedDoc.exists;
      }
    }

    return PostPage(
      posts: posts,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  @override
  Future<String> reFeed({
    required Post original,
    required Feed targetFeed,
    required U user,
  }) async {
    final reFeedRef = _firestore
        .collection('posts')
        .doc(original.id)
        .collection('reFeeds')
        .doc(user.uid);
    final existing = await reFeedRef.get();
    if (existing.exists) {
      final existingId = existing.data()?['postId'];
      if (existingId is String) return existingId;
    }

    final newId = newPostId();

    final feedData = targetFeed.toJson()
      ..addAll({'id': targetFeed.id, 'userId': targetFeed.userId});
    final userData = user.toJson()..addAll({'uid': user.uid});

    await _firestore.collection('posts').doc(newId).set({
      'text': original.text,
      if (original.media != null && original.media!.isNotEmpty)
        'images': original.media,
      'feedId': targetFeed.id,
      'feed': feedData,
      'userId': user.uid,
      'user': userData,
      'reFeeded': true,
      'reFeededFrom': {'id': original.id},
      if (original.nsfw == true) 'nsfw': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await reFeedRef.set({
      'postId': newId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('posts')
        .doc(original.id)
        .update({'reFeeds': FieldValue.increment(1)});
    if (_analytics != null) {
      await _analytics!.logEvent('re_feed', parameters: {
        'postId': newId,
        'originalPostId': original.id,
        'originalFeedId': original.feedId,
        'targetFeedId': targetFeed.id,
        'userId': user.uid,
      });
    }
    return newId;
  }

  @override
  Future<void> deletePost(String id) async {
    final postRef = _firestore.collection('posts').doc(id);
    final snap = await postRef.get();
    String? originalId;
    String? originalFeedId;
    final feedId = snap.data()?['feedId'];
    final userId = snap.data()?['userId'];
    if (snap.exists && (snap.data()?['reFeeded'] == true)) {
      originalId = snap.data()?['reFeededFrom']?['id'];
      final uid = snap.data()?['userId'];
      if (originalId != null && uid != null) {
        await _firestore
            .collection('posts')
            .doc(originalId)
            .collection('reFeeds')
            .doc(uid)
            .delete();
        final origSnap =
            await _firestore.collection('posts').doc(originalId).get();
        originalFeedId = origSnap.data()?['feedId'];
      }
    }
    if (_analytics != null) {
      await _analytics!.logEvent('delete_post', parameters: {
        'postId': id,
        'feedId': feedId,
        'userId': userId,
        if (originalId != null) 'originalPostId': originalId,
        if (originalFeedId != null) 'originalFeedId': originalFeedId,
      });
    }
    await postRef.delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../models/feed.dart';
import 'auth_service.dart';


/// Base interface for creating posts in Firestore.
abstract class BasePostService {
  /// Generates a new unique identifier for a post document.
  String newPostId();

  /// Creates a post document with optional [id].
  Future<void> createPost(Map<String, dynamic> data, {String? id});

  /// Toggles like state for [postId] by [userId].
  Future<void> toggleLike(String postId, String userId, bool like);

  /// Fetches a post document by [id]. Returns null if not found.
  Future<Post?> fetchPost(String id);

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

  PostService({FirebaseFirestore? firestore, AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService;

  @override
  String newPostId() => _firestore.collection('posts').doc().id;

  @override
  Future<void> createPost(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _firestore.collection('posts').doc(id).set(data);
    } else {
      final doc = await _firestore.collection('posts').add(data);
      id = doc.id;
    }
    // Mentions are now handled server-side by a Firestore trigger.
  }

  @override
  Future<void> toggleLike(String postId, String userId, bool like) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);
    await _firestore.runTransaction((txn) async {
      final likeSnap = await txn.get(likeRef);
      final currentlyLiked = likeSnap.exists;
      if (like && !currentlyLiked) {
        txn.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        txn.update(postRef, {'likes': FieldValue.increment(1)});
      } else if (!like && currentlyLiked) {
        txn.delete(likeRef);
        txn.update(postRef, {'likes': FieldValue.increment(-1)});
      }
    });
    // Like notifications are handled server-side by a Firestore trigger.
  }

  @override
  Future<Post?> fetchPost(String id) async {
    final doc = await _firestore.collection('posts').doc(id).get();
    if (!doc.exists) return null;
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

    return newId;
  }

  @override
  Future<void> deletePost(String id) async {
    final postRef = _firestore.collection('posts').doc(id);
    final snap = await postRef.get();
    if (snap.exists && (snap.data()?['reFeeded'] == true)) {
      final originalId = snap.data()?['reFeededFrom']?['id'];
      final uid = snap.data()?['userId'];
      if (originalId != null && uid != null) {
        await _firestore
            .collection('posts')
            .doc(originalId)
            .collection('reFeeds')
            .doc(uid)
            .delete();
      }
    }
    await postRef.delete();
  }
}

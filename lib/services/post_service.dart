import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../models/feed.dart';


/// Base interface for creating posts in Firestore.
abstract class BasePostService {
  /// Generates a new unique identifier for a post document.
  String newPostId();

  /// Creates a post document with optional [id].
  Future<void> createPost(Map<String, dynamic> data, {String? id});

  /// Toggles like state for [postId] by [userId].
  Future<void> toggleLike(String postId, String userId, bool like);

  /// Creates a reFeed of [original] into [targetFeed] by [user].
  /// Returns the new post id.
  Future<String> reFeed({
    required Post original,
    required Feed targetFeed,
    required U user,
  });
}

/// Default implementation writing to the `posts` collection.
class PostService implements BasePostService {
  final FirebaseFirestore _firestore;

  PostService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
      if (like) {
        txn.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        txn.update(postRef, {'likes': FieldValue.increment(1)});
      } else {
        txn.delete(likeRef);
        txn.update(postRef, {'likes': FieldValue.increment(-1)});
      }
    });
    // Like notifications are handled server-side by a Firestore trigger.
  }

  @override
  Future<String> reFeed({
    required Post original,
    required Feed targetFeed,
    required U user,
  }) async {
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

    await _firestore
        .collection('posts')
        .doc(original.id)
        .update({'reFeeds': FieldValue.increment(1)});

    return newId;
  }
}

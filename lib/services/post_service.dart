import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/auth_service.dart';

/// Default implementation writing to the `posts` collection.
class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  String newPostId() => _firestore.collection('posts').doc().id;

  Future<void> createPost(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _firestore.collection('posts').doc(id).set(data);
    } else {
      final doc = await _firestore.collection('posts').add(data);
      id = doc.id;
    }
    // Mentions are now handled server-side by a Firestore trigger.
  }

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

  Future<Post?> fetchPost(String id) async {
    final doc = await _firestore.collection('posts').doc(id).get();
    if (!doc.exists) return null;
    final data = {'id': doc.id, ...doc.data()!};
    if (_authService.currentUser != null) {
      final uid = _authService.currentUser!.uid;
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

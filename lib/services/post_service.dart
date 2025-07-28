import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../models/feed.dart';
import 'notification_service.dart';

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
  final BaseNotificationService _notificationService;

  PostService(
      {FirebaseFirestore? firestore,
      BaseNotificationService? notificationService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ??
            (Get.isRegistered<BaseNotificationService>()
                ? Get.find<BaseNotificationService>()
                : NotificationService());

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
    final text = data['text'] as String?;
    if (text != null && text.contains('@')) {
      final regex = RegExp(r'@([A-Za-z0-9_]+)');
      for (final match in regex.allMatches(text)) {
        final username = match.group(1)!;
        final userQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
        if (userQuery.docs.isEmpty) continue;
        final targetId = userQuery.docs.first.id;
        if (targetId == data['userId']) continue;
        await _notificationService.createNotification(targetId, {
          'user': data['user'],
          if (data['feed'] != null) 'feed': data['feed'],
          'postId': id,
          'type': 2,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
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
    if (like) {
      final postDoc = await postRef.get();
      final ownerId = postDoc.get('userId');
      if (ownerId != userId) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();
        if (userData != null) {
          userData['uid'] = userId;
          final feedData = postDoc.data()?['feed'];
          await _notificationService.createNotification(ownerId, {
            'user': userData,
            if (feedData != null) 'feed': feedData,
            'postId': postId,
            'type': 0,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/comment.dart';
import 'notification_service.dart';

class CommentPage {
  CommentPage({required this.comments, this.lastDoc, this.hasMore = false});

  final List<Comment> comments;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
}

abstract class BaseCommentService {
  Future<CommentPage> fetchComments(
    String postId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  });

  String newCommentId(String postId);

  Future<void> createComment(String postId, Map<String, dynamic> data,
      {String? id});
}

class CommentService implements BaseCommentService {
  final FirebaseFirestore _firestore;
  final BaseNotificationService _notificationService;

  CommentService(
      {FirebaseFirestore? firestore,
      BaseNotificationService? notificationService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ??
            (Get.isRegistered<BaseNotificationService>()
                ? Get.find<BaseNotificationService>()
                : NotificationService());

  @override
  Future<CommentPage> fetchComments(
    String postId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    var query = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final comments = snapshot.docs
        .map((d) => Comment.fromJson({'id': d.id, ...d.data()}))
        .toList();

    return CommentPage(
      comments: comments,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  @override
  String newCommentId(String postId) => _firestore
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc()
      .id;

  @override
  Future<void> createComment(String postId, Map<String, dynamic> data,
      {String? id}) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    await _firestore.runTransaction((txn) async {
      final doc = id != null ? commentsRef.doc(id) : commentsRef.doc();
      txn.set(doc, data);
      txn.update(postRef, {'comments': FieldValue.increment(1)});
    });
    final postDoc = await postRef.get();
    final ownerId = postDoc.get('userId');
    if (ownerId != data['userId']) {
      await _notificationService.createNotification(ownerId, {
        'user': data['user'],
        if (data['feed'] != null) 'feed': data['feed'],
        'postId': postId,
        'type': 1,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
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
          'postId': postId,
          'type': 2,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}

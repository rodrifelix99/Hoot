import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment.dart';

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

  Future<void> createComment(String postId, Map<String, dynamic> data, {String? id});
}

class CommentService implements BaseCommentService {
  final FirebaseFirestore _firestore;

  CommentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
  Future<void> createComment(String postId, Map<String, dynamic> data, {String? id}) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    await _firestore.runTransaction((txn) async {
      final doc = id != null ? commentsRef.doc(id) : commentsRef.doc();
      txn.set(doc, data);
      txn.update(postRef, {'comments': FieldValue.increment(1)});
    });
  }
}

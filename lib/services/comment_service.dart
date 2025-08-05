import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/comment.dart';
import 'package:hoot/util/constants.dart';

class CommentPage {
  CommentPage({required this.comments, this.lastDoc, this.hasMore = false});

  final List<Comment> comments;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
}

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CommentPage> fetchComments(
    String postId, {
    DocumentSnapshot? startAfter,
    int limit = kDefaultFetchLimit,
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

  String newCommentId(String postId) => _firestore
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc()
      .id;

  Future<void> createComment(String postId, Map<String, dynamic> data,
      {String? id}) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    await _firestore.runTransaction((txn) async {
      final doc = id != null ? commentsRef.doc(id) : commentsRef.doc();
      txn.set(doc, data);
      txn.update(postRef, {'comments': FieldValue.increment(1)});
    });
    // Notification creation is handled server-side by Firestore triggers.
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);
    await _firestore.runTransaction((txn) async {
      txn.delete(commentRef);
      txn.update(postRef, {'comments': FieldValue.increment(-1)});
    });
  }
}

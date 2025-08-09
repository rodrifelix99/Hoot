import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hoot/models/comment.dart';
import 'package:hoot/services/analytics_service.dart';
import 'package:hoot/util/constants.dart';

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
    int limit = kDefaultFetchLimit,
  });

  String newCommentId(String postId);

  Future<void> createComment(String postId, Map<String, dynamic> data,
      {String? id});

  Future<void> deleteComment(String postId, String commentId);
}

class CommentService implements BaseCommentService {
  final FirebaseFirestore _firestore;

  CommentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  @override
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

    if (snapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final d in snapshot.docs) {
        batch.update(d.reference, {'views': FieldValue.increment(1)});
      }
      await batch.commit();
    }

    final comments = snapshot.docs
        .map((d) => Comment.fromJson({'id': d.id, ...d.data()}))
        .toList();

    if (_analytics != null) {
      await _analytics!.logEvent('fetch_comments', parameters: {
        'postId': postId,
        'count': comments.length,
      });
    }

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

    final doc = id != null ? commentsRef.doc(id) : commentsRef.doc();
    final commentId = doc.id;
    await _firestore.runTransaction((txn) async {
      txn.set(doc, data);
      txn.update(postRef, {'comments': FieldValue.increment(1)});
    });
    if (_analytics != null) {
      await _analytics!.logEvent('create_comment', parameters: {
        'postId': postId,
        'commentId': commentId,
        'authorId': data['userId'],
        'textLength': (data['text'] as String?)?.length ?? 0,
      });
    }
    // Notification creation is handled server-side by Firestore triggers.
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);
    await _firestore.runTransaction((txn) async {
      txn.delete(commentRef);
      txn.update(postRef, {'comments': FieldValue.increment(-1)});
    });
    if (_analytics != null) {
      await _analytics!.logEvent('delete_comment', parameters: {
        'postId': postId,
        'commentId': commentId,
      });
    }
  }
}

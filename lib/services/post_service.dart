import 'package:cloud_firestore/cloud_firestore.dart';

/// Base interface for creating posts in Firestore.
abstract class BasePostService {
  /// Generates a new unique identifier for a post document.
  String newPostId();

  /// Creates a post document with optional [id].
  Future<void> createPost(Map<String, dynamic> data, {String? id});
}

/// Default implementation writing to the `posts` collection.
class PostService implements BasePostService {
  final FirebaseFirestore _firestore;

  PostService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  String newPostId() => _firestore.collection('posts').doc().id;

  @override
  Future<void> createPost(Map<String, dynamic> data, {String? id}) {
    if (id != null) {
      return _firestore.collection('posts').doc(id).set(data);
    }
    return _firestore.collection('posts').add(data);
  }
}

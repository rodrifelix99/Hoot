import 'package:cloud_firestore/cloud_firestore.dart';

/// Base interface for creating posts in Firestore.
abstract class BasePostService {
  Future<void> createPost(Map<String, dynamic> data);
}

/// Default implementation writing to the `posts` collection.
class PostService implements BasePostService {
  final FirebaseFirestore _firestore;

  PostService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost(Map<String, dynamic> data) {
    return _firestore.collection('posts').add(data);
  }
}

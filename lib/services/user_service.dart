import 'package:cloud_firestore/cloud_firestore.dart';

/// Provides helpers to update and query user documents.
abstract class BaseUserService {
  Future<void> updateUserData(String uid, Map<String, dynamic> data);
  Future<bool> isUsernameAvailable(String username);
}

/// Default implementation that persists data to Firestore.
class UserService implements BaseUserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> updateUserData(String uid, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final existing = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return existing.docs.isEmpty;
  }
}

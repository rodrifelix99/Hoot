import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/user.dart';

/// Provides helpers to update and query user documents.
abstract class BaseUserService {
  Future<void> updateUserData(String uid, Map<String, dynamic> data);
  Future<bool> isUsernameAvailable(String username);
  Future<List<U>> searchUsers(String query);
}

/// Default implementation that persists data to Firestore.
class UserService implements BaseUserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> updateUserData(String uid, Map<String, dynamic> data) {
    final updated = Map<String, dynamic>.from(data);
    if (updated.containsKey('username')) {
      updated['usernameLowercase'] =
          (updated['username'] as String?)?.toLowerCase();
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .set(updated, SetOptions(merge: true));
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

  @override
  Future<List<U>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(5)
        .get();
    return snapshot.docs.map((d) => U.fromJson(d.data())).toList();
  }
}

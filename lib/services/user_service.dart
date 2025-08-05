import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/user.dart';

/// Provides helpers to update and query user documents.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserData(String uid, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<bool> isUsernameAvailable(String username) async {
    final existing = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return existing.docs.isEmpty;
  }

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

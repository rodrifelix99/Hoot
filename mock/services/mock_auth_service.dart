import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart' as real;

import '../data/mock_user.dart';

/// Mock implementation of [AuthService] providing in-memory user data.
class MockAuthService extends real.AuthService {
  final U user;
  MockAuthService({DateTime? createdAt})
      : user = createMockUser(createdAt: createdAt),
        super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());

  @override
  Future<U?> fetchUser() async {
    currentUserRx.value = user;
    return currentUserRx.value;
  }

  @override
  Future<U?> fetchUserById(String uid) async {
    return uid == user.uid ? user : null;
  }

  @override
  Future<U?> fetchUserByUsername(String username) async {
    return username == user.username ? user : null;
  }

  @override
  Future<List<U>> searchUsers(String query, {int limit = 5}) async {
    if (user.username != null && user.username!.startsWith(query)) {
      return [user];
    }
    return [];
  }

  @override
  Future<void> signOut() async {
    currentUserRx.value = null;
  }
}

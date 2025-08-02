import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart' as real;

import '../data/mock_user.dart';

/// Mock implementation of [AuthService] providing in-memory user data.
class MockAuthService extends real.AuthService {
  MockAuthService()
      : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());

  @override
  Future<U?> fetchUser() async {
    currentUserRx.value = mockUser;
    return currentUserRx.value;
  }

  @override
  Future<U?> fetchUserById(String uid) async {
    return uid == mockUser.uid ? mockUser : null;
  }

  @override
  Future<U?> fetchUserByUsername(String username) async {
    return username == mockUser.username ? mockUser : null;
  }

  @override
  Future<List<U>> searchUsers(String query, {int limit = 5}) async {
    if (mockUser.username != null && mockUser.username!.startsWith(query)) {
      return [mockUser];
    }
    return [];
  }

  @override
  Future<void> signOut() async {
    currentUserRx.value = null;
  }
}

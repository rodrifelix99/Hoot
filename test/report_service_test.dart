import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/services/report_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/models/user.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U? _user;
  FakeAuthService(this._user);

  @override
  U? get currentUser => _user;

  @override
  Stream<U?> get currentUserStream => Stream.value(_user);

  @override
  Rxn<U> get currentUserRx => Rxn<U>()..value = _user;

  @override
  Future<U?> fetchUser() async => _user;

  @override
  Future<U?> fetchUserById(String uid) async => _user;

  @override
  Future<U?> fetchUserByUsername(String username) async => _user;

  @override
  Future<List<U>> searchUsers(String query, {int limit = 5}) async => [];

  @override
  Future<void> signOut() async {}

  @override
  Future<UserCredential> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserCredential> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<U?> refreshUser() async => _user;

  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}

  @override
  String? displayName;

  @override
  bool get isStaff => false;
}

void main() {
  group('ReportService', () {
    test('reportComment writes correct payload', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = FakeAuthService(U(uid: 'u1'));
      final service = ReportService(firestore: firestore, authService: auth);

      await service.reportComment(commentId: 'c1', reason: 'spam');

      final snapshot = await firestore.collection('reports').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['type'], 'comment');
      expect(data['targetId'], 'c1');
      expect(data['userId'], 'u1');
      expect(data['reason'], 'spam');
      expect(data['resolved'], false);
      expect(data['createdAt'], isNotNull);
    });
  });
}

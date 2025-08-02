import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/user.dart';
import 'package:hoot/pages/edit_profile/controllers/edit_profile_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/user_service.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U _user;
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
}

class FakeUserService implements BaseUserService {
  final Map<String, Map<String, dynamic>> updates = {};

  @override
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    updates[uid] = data;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

  @override
  Future<List<U>> searchUsers(String query) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saveProfile persists location and website', (tester) async {
    await tester.pumpWidget(
        const ToastificationWrapper(child: MaterialApp(home: Scaffold())));

    final user = U(uid: 'u1', name: 'Old');
    final auth = FakeAuthService(user);
    final userService = FakeUserService();
    Get.put<AuthService>(auth);
    final controller =
        EditProfileController(authService: auth, userService: userService);

    controller.nameController.text = 'New Name';
    controller.selectedCity.value = 'Berlin, Germany';
    controller.websiteController.text = 'https://example.com';

    final result = await controller.saveProfile();
    await tester.pump(const Duration(seconds: 4));
    expect(result, isTrue);
    expect(user.location, 'Berlin, Germany');
    expect(user.website, 'https://example.com');
    expect(userService.updates['u1']?['location'], 'Berlin, Germany');
    expect(userService.updates['u1']?['website'], 'https://example.com');

    Get.reset();
  });
}

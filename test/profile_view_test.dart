import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/pages/profile/views/profile_view.dart';
import 'package:hoot/services/auth_service.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U _user;
  FakeAuthService(this._user);

  @override
  U? get currentUser => _user;

  @override
  Future<U?> fetchUser() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserCredential> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserCredential> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('ProfileView shows profile information', (tester) async {
    final user = U(
      uid: '1',
      name: 'Tester',
      username: 'tester',
      bio: 'Hello',
      feeds: [Feed(id: 'f1', title: 'Feed 1', description: 'desc')],
    );
    final service = FakeAuthService(user);
    final controller = ProfileController(authService: service);
    Get.put<AuthService>(service);
    Get.put<ProfileController>(controller);

    await tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(body: ProfileView()),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('@tester'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Feed 1'), findsOneWidget);
  });
}

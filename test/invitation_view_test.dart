import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hoot/pages/invitation/controllers/invitation_controller.dart';
import 'package:hoot/pages/invitation/views/invitation_view.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:hoot/services/invitation_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/user.dart';

class FakeInvitationService extends InvitationService {
  FakeInvitationService() : super(firestore: FakeFirebaseFirestore());
  @override
  Future<bool> useInvitationCode(String newUserId, String code) async => true;
}

class FakeAuthService extends GetxService implements AuthService {
  @override
  U? get currentUser => U(uid: 'u1');

  @override
  Future<U?> fetchUser() async => currentUser;

  @override
  Future<U?> fetchUserById(String uid) async => currentUser;

  @override
  Future<U?> fetchUserByUsername(String username) async => currentUser;

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
  Future<U?> refreshUser() async => currentUser;
}

void main() {
  testWidgets('InvitationView shows prompt text', (tester) async {
    Get.put<AuthService>(FakeAuthService());
    Get.put<InvitationController>(
        InvitationController(invitationService: FakeInvitationService()));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        theme: AppTheme.lightTheme,
        home: const InvitationView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Access is limited. Entry requires a personal invite.'),
        findsOneWidget);
    addTearDown(Get.reset);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/pages/invite_friends/controllers/invite_friends_controller.dart';
import 'package:hoot/pages/invite_friends/views/invite_friends_view.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/invitation_service.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/util/translations/app_translations.dart';

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

  @override
  String? displayName;

  @override
  bool get isStaff => false;
}

class FakeInvitationService extends GetxService implements InvitationService {
  @override
  Future<bool> useInvitationCode(String newUserId, String code) async => false;

  @override
  Future<int> getRemainingInvites(String userId) async => 3;
}

void main() {
  testWidgets('InviteFriendsView shows invite code and remaining count',
      (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(binding.window.clearPhysicalSizeTestValue);
    addTearDown(binding.window.clearDevicePixelRatioTestValue);

    final user = U(uid: 'u1', invitationCode: 'CODE1234');
    final auth = FakeAuthService(user);
    final inviteService = FakeInvitationService();
    Get.put<AuthService>(auth);
    Get.put<InvitationService>(inviteService);
    Get.put(InviteFriendsController(
        authService: auth, invitationService: inviteService));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const InviteFriendsView(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CODE1234'), findsOneWidget);
    expect(find.text('3 invites left this month'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/pages/welcome/controllers/welcome_controller.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/user_service.dart';

class _FakeUserService implements BaseUserService {
  String? lastUid;
  Map<String, dynamic>? lastData;
  bool usernameAvailable = true;

  @override
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    lastUid = uid;
    lastData = data;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    return usernameAvailable;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('displayNameController text initialized from auth user name', () {
    final authService = AuthService(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );
    authService.currentUserRx.value = U(uid: 'u1');
    authService.displayName = 'Jane';
    Get.put<AuthService>(authService);

    final controller = WelcomeController(userService: _FakeUserService());
    controller.onInit();

    expect(controller.displayNameController.text, 'Jane');

    controller.onClose();
  });

  test('saveDisplayName uses AuthService uid', () async {
    final authService = AuthService(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );
    authService.currentUserRx.value = U(uid: 'u1');
    Get.put<AuthService>(authService);
    final userService = _FakeUserService();

    final controller = WelcomeController(userService: userService);
    controller.displayNameController.text = 'Jane';
    final result = await controller.saveDisplayName();

    expect(result, isTrue);
    expect(userService.lastUid, 'u1');
    expect(userService.lastData?['displayName'], 'Jane');
    expect(authService.currentUser?.name, 'Jane');

    controller.onClose();
  });

  test('saveUsername uses AuthService uid', () async {
    final authService = AuthService(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );
    authService.currentUserRx.value = U(uid: 'u1');
    Get.put<AuthService>(authService);
    final userService = _FakeUserService();

    final controller = WelcomeController(userService: userService);
    controller.usernameController.text = 'jane_doe';
    final result = await controller.saveUsername();

    expect(result, isTrue);
    expect(userService.lastUid, 'u1');
    expect(userService.lastData?['username'], 'jane_doe');
    expect(userService.lastData?['usernameLowercase'], 'jane_doe');
    expect(authService.currentUser?.username, 'jane_doe');

    controller.onClose();
  });
}

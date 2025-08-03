import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/pages/welcome/controllers/welcome_controller.dart';
import 'package:hoot/models/user.dart';

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
    authService.currentUserRx.value = U(uid: 'u1', name: 'Jane');
    Get.put<AuthService>(authService);

    final controller = WelcomeController();
    controller.onInit();

    expect(controller.displayNameController.text, 'Jane');

    controller.onClose();
  });
}

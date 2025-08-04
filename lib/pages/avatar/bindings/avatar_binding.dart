import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'package:hoot/pages/avatar/controllers/avatar_controller.dart';
import 'package:hoot/services/auth_service.dart';

class AvatarBinding extends Bindings {
  @override
  void dependencies() {
    final authService = Get.find<AuthService>();
    final bool isMock = authService.runtimeType.toString().contains('Mock');
    final FirebaseFirestore firestore =
        isMock ? FakeFirebaseFirestore() : FirebaseFirestore.instance;
    final FirebaseStorage storage = FirebaseStorage.instance;

    Get.lazyPut(() => AvatarController(
          authService: authService,
          firestore: firestore,
          storage: storage,
        ));
  }
}

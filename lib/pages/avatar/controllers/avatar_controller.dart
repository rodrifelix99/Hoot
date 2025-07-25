import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/error_service.dart';
import '../../../services/auth_service.dart';
import '../../../util/routes/app_routes.dart';

class AvatarController extends GetxController {
  final _auth = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  final Rx<File?> avatarFile = Rx<File?>(null);
  final RxString avatarMessage = ''.obs;
  final RxBool uploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    avatarMessage.value = 'tapToPickAvatar'.tr;
  }

  /// Prompts the user to pick an image from the gallery.
  Future<void> pickAvatar() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      avatarFile.value = File(picked.path);
      final messages = [
        'avatarSelectedFunny1'.tr,
        'avatarSelectedFunny2'.tr,
        'avatarSelectedFunny3'.tr,
      ];
      avatarMessage.value = messages[Random().nextInt(messages.length)];
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    }
  }

  /// Completes the onboarding flow, uploads the avatar and
  /// triggers the welcome notification.
  Future<void> finishOnboarding() async {
    if (uploading.value) return;
    uploading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && avatarFile.value != null) {
        final file = avatarFile.value!;
        final ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child(uid)
            .child('avatar.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'smallAvatar': url,
          'bigAvatar': url,
        }, SetOptions(merge: true));
        final user = _auth.currentUser;
        if (user != null) {
          user.smallProfilePictureUrl = url;
          user.largeProfilePictureUrl = url;
        }
      }

      // Push notification logic removed temporarily
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    } finally {
      uploading.value = false;
      Get.offAllNamed(AppRoutes.home);
    }
  }
}

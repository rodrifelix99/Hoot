import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:blurhash/blurhash.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/routes/app_routes.dart';

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
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final small = img.copyResizeCropSquare(decoded, size: 48);
          final big = img.copyResizeCropSquare(decoded, size: 512);

          final smallData = Uint8List.fromList(img.encodeJpg(small));
          final bigData = Uint8List.fromList(img.encodeJpg(big));

          final smallHash = await BlurHash.encode(smallData, 4, 3);
          final bigHash = await BlurHash.encode(bigData, 4, 3);

          final storageRef =
              FirebaseStorage.instance.ref().child('avatars').child(uid);

          final smallRef = storageRef.child('small_avatar.jpg');
          final bigRef = storageRef.child('big_avatar.jpg');

          await smallRef.putData(
              smallData, SettableMetadata(contentType: 'image/jpeg'));
          await bigRef.putData(
              bigData, SettableMetadata(contentType: 'image/jpeg'));

          final smallUrl = await smallRef.getDownloadURL();
          final bigUrl = await bigRef.getDownloadURL();

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'smallAvatar': smallUrl,
            'bigAvatar': bigUrl,
            'smallAvatarHash': smallHash,
            'bigAvatarHash': bigHash,
          }, SetOptions(merge: true));

          final user = _auth.currentUser;
          if (user != null) {
            user.smallProfilePictureUrl = smallUrl;
            user.largeProfilePictureUrl = bigUrl;
            user.smallAvatarHash = smallHash;
            user.bigAvatarHash = bigHash;
          }
        }
      }

      // Push notification logic removed temporarily
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    } finally {
      uploading.value = false;
      Get.offAllNamed(AppRoutes.invitation);
    }
  }
}

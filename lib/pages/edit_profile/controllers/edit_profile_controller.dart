import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash/blurhash.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/user_service.dart';
import 'package:hoot/models/user.dart';

class EditProfileController extends GetxController {
  final AuthService _authService;
  final BaseUserService _userService;
  final ImagePicker _picker = ImagePicker();

  EditProfileController(
      {AuthService? authService, BaseUserService? userService})
      : _authService = authService ?? Get.find<AuthService>(),
        _userService = userService ?? UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final Rx<File?> bannerFile = Rx<File?>(null);
  final Rx<File?> avatarFile = Rx<File?>(null);
  final RxBool saving = false.obs;

  U? get user => _authService.currentUser;

  @override
  void onInit() {
    super.onInit();
    final u = user;
    if (u != null) {
      nameController.text = u.name ?? '';
      bioController.text = u.bio ?? '';
    }
  }

  Future<void> pickBanner() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        bannerFile.value = File(picked.path);
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    }
  }

  Future<void> pickAvatar() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        avatarFile.value = File(picked.path);
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    }
  }

  Future<bool> saveProfile() async {
    if (saving.value) return false;

    final name = nameController.text.trim();
    final bio = bioController.text.trim();

    if (name.length < 3) {
      ToastService.showError('displayNameTooShort'.tr);
      return false;
    }

    saving.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      String? bannerUrl;
      String? bannerHash;
      if (bannerFile.value != null) {
        final file = bannerFile.value!;
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        Uint8List data = bytes;
        if (decoded != null) {
          final resized = img.copyResize(decoded, height: 1024);
          data = Uint8List.fromList(img.encodeJpg(resized));
          bannerHash = await BlurHash.encode(data, 4, 3);
        }
        final ref = FirebaseStorage.instance
            .ref()
            .child('banners')
            .child(uid)
            .child('banner.jpg');
        await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
        bannerUrl = await ref.getDownloadURL();
      }

      String? smallAvatarUrl;
      String? bigAvatarUrl;
      String? smallAvatarHash;
      String? bigAvatarHash;
      if (avatarFile.value != null) {
        final file = avatarFile.value!;
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final small = img.copyResizeCropSquare(decoded, size: 48);
          final big = img.copyResizeCropSquare(decoded, size: 512);
          final smallData = Uint8List.fromList(img.encodeJpg(small));
          final bigData = Uint8List.fromList(img.encodeJpg(big));
          smallAvatarHash = await BlurHash.encode(smallData, 4, 3);
          bigAvatarHash = await BlurHash.encode(bigData, 4, 3);
          final storageRef =
              FirebaseStorage.instance.ref().child('avatars').child(uid);
          final smallRef = storageRef.child('small_avatar.jpg');
          final bigRef = storageRef.child('big_avatar.jpg');
          await smallRef.putData(
              smallData, SettableMetadata(contentType: 'image/jpeg'));
          await bigRef.putData(
              bigData, SettableMetadata(contentType: 'image/jpeg'));
          smallAvatarUrl = await smallRef.getDownloadURL();
          bigAvatarUrl = await bigRef.getDownloadURL();
        }
      }

      await _userService.updateUserData(uid, {
        'displayName': name,
        'bio': bio,
        if (bannerUrl != null) 'banner': bannerUrl,
        if (bannerHash != null) 'bannerHash': bannerHash,
        if (smallAvatarUrl != null) 'smallAvatar': smallAvatarUrl,
        if (bigAvatarUrl != null) 'bigAvatar': bigAvatarUrl,
        if (smallAvatarHash != null) 'smallAvatarHash': smallAvatarHash,
        if (bigAvatarHash != null) 'bigAvatarHash': bigAvatarHash,
      });

      final u = user;
      if (u != null) {
        u.name = name;
        u.bio = bio;
        if (bannerUrl != null) u.bannerPictureUrl = bannerUrl;
        if (bannerHash != null) u.bannerHash = bannerHash;
        if (smallAvatarUrl != null) u.smallProfilePictureUrl = smallAvatarUrl;
        if (bigAvatarUrl != null) u.largeProfilePictureUrl = bigAvatarUrl;
        if (smallAvatarHash != null) u.smallAvatarHash = smallAvatarHash;
        if (bigAvatarHash != null) u.bigAvatarHash = bigAvatarHash;
      }

      ToastService.showSuccess('editProfile'.tr);
      return true;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return false;
    } finally {
      saving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

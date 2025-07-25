import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../../services/auth_service.dart';
import '../../../services/error_service.dart';
import '../../../services/toast_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user.dart';

class EditProfileController extends GetxController {
  final AuthService _authService;
  final BaseUserService _userService;
  final ImagePicker _picker = ImagePicker();

  EditProfileController(
      {AuthService? authService, BaseUserService? userService})
      : _authService = authService ?? Get.find<AuthService>(),
        _userService = userService ?? UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final Rx<File?> bannerFile = Rx<File?>(null);
  final RxBool saving = false.obs;

  U? get user => _authService.currentUser;

  @override
  void onInit() {
    super.onInit();
    final u = user;
    if (u != null) {
      nameController.text = u.name ?? '';
      usernameController.text = u.username ?? '';
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

  Future<bool> saveProfile() async {
    if (saving.value) return false;

    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final bio = bioController.text.trim();

    if (name.length < 3) {
      ToastService.showError('displayNameTooShort'.tr);
      return false;
    }
    if (username.length < 6) {
      ToastService.showError('usernameTooShort'.tr);
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+\$').hasMatch(username)) {
      ToastService.showError('usernameInvalid'.tr);
      return false;
    }

    saving.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      String? bannerUrl;
      if (bannerFile.value != null) {
        final file = bannerFile.value!;
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        Uint8List data = bytes;
        if (decoded != null) {
          final resized = img.copyResize(decoded, height: 256);
          data = Uint8List.fromList(img.encodeJpg(resized));
        }
        final ref = FirebaseStorage.instance
            .ref()
            .child('banners')
            .child(uid)
            .child('banner.jpg');
        await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
        bannerUrl = await ref.getDownloadURL();
      }

      await _userService.updateUserData(uid, {
        'displayName': name,
        'username': username,
        'bio': bio,
        if (bannerUrl != null) 'banner': bannerUrl,
      });

      final u = user;
      if (u != null) {
        u.name = name;
        u.username = username;
        u.bio = bio;
        if (bannerUrl != null) u.bannerPictureUrl = bannerUrl;
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
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

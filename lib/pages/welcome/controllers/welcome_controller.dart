import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/user_service.dart';

/// Manages the state of the welcome flow including form controllers
/// and Firestore updates.
class WelcomeController extends GetxController {
  final displayNameController = TextEditingController();
  final usernameController = TextEditingController();

  final _auth = Get.find<AuthService>();
  final BaseUserService _userService;

  WelcomeController({BaseUserService? userService})
      : _userService = userService ?? UserService();

  /// Validates and saves the display name to Firestore.
  Future<bool> saveDisplayName() async {
    final name = displayNameController.text.trim();
    if (name.length < 3) {
      ToastService.showError('displayNameTooShort'.tr);
      return false;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final user = _auth.currentUser;
    if (user != null) {
      user.name = name;
      await _userService.updateUserData(uid, user.toCache());
    } else {
      await _userService.updateUserData(uid, {
        'uid': uid,
        'displayName': name,
      });
    }
    _auth.currentUser?.name = name;
    return true;
  }

  /// Validates the username, checks availability and saves it to Firestore.
  Future<bool> saveUsername() async {
    final username = usernameController.text.trim();

    if (username.length < 6) {
      ToastService.showError('usernameTooShort'.tr);
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      ToastService.showError('usernameInvalid'.tr);
      return false;
    }

    final available = await _userService.isUsernameAvailable(username);
    if (!available) {
      ToastService.showError('usernameTaken'.tr);
      return false;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final user = _auth.currentUser;
    if (user != null) {
      user.username = username;
      await _userService.updateUserData(uid, user.toCache());
    } else {
      await _userService.updateUserData(uid, {
        'uid': uid,
        'username': username,
      });
    }
    _auth.currentUser?.username = username;
    return true;
  }

  @override
  void onClose() {
    displayNameController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}

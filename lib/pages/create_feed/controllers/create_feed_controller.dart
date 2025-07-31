import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash/blurhash.dart';

import '../../../services/toast_service.dart';
import '../../../services/error_service.dart';
import '../../../util/enums/feed_types.dart';
import '../../../services/auth_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../models/feed.dart';

/// Controller handling the create feed form.
class CreateFeedController extends GetxController {
  final FirebaseFirestore _firestore;
  final String _userId;
  final AuthService _authService;
  final ProfileController? _profileController;

  CreateFeedController({
    FirebaseFirestore? firestore,
    AuthService? authService,
    ProfileController? profileController,
    String? userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? Get.find<AuthService>(),
        _profileController = profileController ??
            (Get.isRegistered<ProfileController>(tag: 'current')
                ? Get.find<ProfileController>(tag: 'current')
                : null),
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Controllers for title and description fields.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  /// Selected feed color.
  final Rx<Color> selectedColor = Rx<Color>(Colors.blue);

  /// Chosen feed genre.
  final Rx<FeedType?> selectedType = Rx<FeedType?>(null);

  /// Search controller for genre dropdown.
  final TextEditingController typeSearchController = TextEditingController();

  /// Whether the feed is private.
  final RxBool isPrivate = false.obs;

  /// Whether the feed is marked NSFW.
  final RxBool isNsfw = false.obs;

  /// Selected avatar file.
  final Rx<File?> avatarFile = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  /// Whether a feed is currently being created.
  final RxBool creating = false.obs;

  /// Prompts the user to pick an avatar image.
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

  /// Creates the feed in Firestore after validating input.
  Future<bool> createFeed() async {
    if (creating.value) return false;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final type = selectedType.value;

    if (title.isEmpty) {
      ToastService.showError('titleRequired'.tr);
      return false;
    }
    if (type == null) {
      ToastService.showError('genreRequired'.tr);
      return false;
    }

    creating.value = true;
    try {
      final docRef = _firestore.collection('feeds').doc();
      String? smallAvatarUrl;
      String? bigAvatarUrl;
      String? smallAvatarHash;
      String? bigAvatarHash;
      if (avatarFile.value != null) {
        final file = avatarFile.value!;
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final small = img.copyResizeCropSquare(decoded, size: 32);
          final big = img.copyResizeCropSquare(decoded, size: 1024);
          final smallData = Uint8List.fromList(img.encodeJpg(small));
          final bigData = Uint8List.fromList(img.encodeJpg(big));
          smallAvatarHash = await BlurHash.encode(smallData, 4, 3);
          bigAvatarHash = await BlurHash.encode(bigData, 4, 3);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('feed_avatars')
              .child(docRef.id);
          final smallRef = storageRef.child('small_avatar.jpg');
          final bigRef = storageRef.child('big_avatar.jpg');
          await smallRef.putData(
              smallData, SettableMetadata(contentType: 'image/jpeg'));
          await bigRef.putData(
              bigData, SettableMetadata(contentType: 'image/jpeg'));
          smallAvatarUrl = await smallRef.getDownloadURL();
          bigAvatarUrl = await bigRef.getDownloadURL();
        }
      } else {
        smallAvatarUrl = _authService.currentUser?.smallProfilePictureUrl;
        bigAvatarUrl = _authService.currentUser?.largeProfilePictureUrl;
      }

      await docRef.set({
        'title': title,
        'description': description,
        'color': selectedColor.value.value.toString(),
        'type': type.toString().split('.').last,
        'private': isPrivate.value,
        'nsfw': isNsfw.value,
        'userId': _userId,
        if (smallAvatarUrl != null) 'smallAvatar': smallAvatarUrl,
        if (bigAvatarUrl != null) 'bigAvatar': bigAvatarUrl,
        if (smallAvatarHash != null) 'smallAvatarHash': smallAvatarHash,
        if (bigAvatarHash != null) 'bigAvatarHash': bigAvatarHash,
        'subscriberCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('subscriptions')
          .doc(docRef.id)
          .set({'createdAt': FieldValue.serverTimestamp()});
      final feed = Feed(
        id: docRef.id,
        userId: _userId,
        smallAvatar: smallAvatarUrl,
        bigAvatar: bigAvatarUrl,
        smallAvatarHash: smallAvatarHash,
        bigAvatarHash: bigAvatarHash,
        title: title,
        description: description,
        color: selectedColor.value,
        type: type,
        private: isPrivate.value,
        nsfw: isNsfw.value,
        subscriberCount: 0,
      );
      final user = _authService.currentUser;
      if (user != null) {
        user.feeds = (user.feeds ?? [])..add(feed);
      }
      _profileController?.feeds.add(feed);
      ToastService.showSuccess('createFeed'.tr);
      titleController.clear();
      descriptionController.clear();
      selectedType.value = null;
      isPrivate.value = false;
      isNsfw.value = false;
      return true;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return false;
    } finally {
      creating.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    typeSearchController.dispose();
    avatarFile.value = null;
    super.onClose();
  }
}

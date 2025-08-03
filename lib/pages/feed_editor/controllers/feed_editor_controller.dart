import 'dart:io';
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/dialog_service.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/util/enums/feed_types.dart';
import 'package:hoot/util/constants.dart';

/// Controller for creating and editing feeds.
class FeedEditorController extends GetxController {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final ProfileController? _profileController;
  final String _userId;

  /// Feed being edited. Null when creating a new feed.
  Feed? feed;

  FeedEditorController({
    FirebaseFirestore? firestore,
    AuthService? authService,
    ProfileController? profileController,
    String? userId,
    this.feed,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? Get.find<AuthService>(),
        _profileController = profileController ??
            (Get.isRegistered<ProfileController>(tag: 'current')
                ? Get.find<ProfileController>(tag: 'current')
                : null),
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Controllers for title/description fields and genre search.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeSearchController = TextEditingController();

  /// Selected color and genre.
  final Rx<Color> selectedColor = Rx<Color>(Colors.blue);
  final Rx<FeedType?> selectedType = Rx<FeedType?>(null);

  /// Privacy/NSFW flags.
  final RxBool isPrivate = false.obs;
  final RxBool isNsfw = false.obs;

  /// Avatar file chosen by user.
  final Rx<File?> avatarFile = Rx<File?>(null);

  /// Whether submit or delete actions are in progress.
  final RxBool submitting = false.obs;
  final RxBool deleting = false.obs;

  final ImagePicker _picker = ImagePicker();

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

  @override
  void onInit() {
    super.onInit();
    feed ??= Get.arguments as Feed?;
    if (feed != null) {
      titleController.text = feed!.title;
      descriptionController.text = feed!.description ?? '';
      selectedColor.value = feed!.color ?? Colors.blue;
      selectedType.value = feed!.type;
      isPrivate.value = feed!.private ?? false;
      isNsfw.value = feed!.nsfw ?? false;
    }
  }

  /// Creates a new feed or saves changes to an existing one.
  Future<bool> submit() async {
    if (submitting.value) return false;

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

    submitting.value = true;
    try {
      if (feed == null) {
        return await _createFeed(title, description, type);
      } else {
        return await _saveFeed(title, description, type);
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return false;
    } finally {
      submitting.value = false;
    }
  }

  Future<bool> _createFeed(
      String title, String description, FeedType type) async {
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
        final small = img.copyResizeCropSquare(decoded, size: kSmallAvatarSize);
        final big =
            img.copyResizeCropSquare(decoded, size: kLargeImageDimension);
        final smallData = Uint8List.fromList(img.encodeJpg(small));
        final bigData = Uint8List.fromList(img.encodeJpg(big));
        smallAvatarHash =
            await BlurHash.encode(smallData, kBlurHashX, kBlurHashY);
        bigAvatarHash = await BlurHash.encode(bigData, kBlurHashX, kBlurHashY);
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

    final order = _profileController?.feeds.length ??
        _authService.currentUser?.feeds?.length ??
        0;

    await docRef.set({
      'title': title,
      'description': description,
      'color': selectedColor.value.value.toString(),
      'type': type.toString().split('.').last,
      'private': isPrivate.value,
      'nsfw': isNsfw.value,
      'userId': _userId,
      'order': order,
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

    final newFeed = Feed(
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
      order: order,
      subscriberCount: 0,
    );
    final user = _authService.currentUser;
    if (user != null) {
      user.feeds = (user.feeds ?? [])..add(newFeed);
    }
    _profileController?.feeds.add(newFeed);
    ToastService.showSuccess('feedCreated'.tr);
    titleController.clear();
    descriptionController.clear();
    selectedType.value = null;
    isPrivate.value = false;
    isNsfw.value = false;
    return true;
  }

  Future<bool> _saveFeed(
      String title, String description, FeedType type) async {
    String? smallAvatarUrl;
    String? bigAvatarUrl;
    String? smallAvatarHash;
    String? bigAvatarHash;
    if (avatarFile.value != null) {
      final file = avatarFile.value!;
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final small = img.copyResizeCropSquare(decoded, size: kSmallAvatarSize);
        final big =
            img.copyResizeCropSquare(decoded, size: kLargeImageDimension);
        final smallData = Uint8List.fromList(img.encodeJpg(small));
        final bigData = Uint8List.fromList(img.encodeJpg(big));
        smallAvatarHash =
            await BlurHash.encode(smallData, kBlurHashX, kBlurHashY);
        bigAvatarHash = await BlurHash.encode(bigData, kBlurHashX, kBlurHashY);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('feed_avatars')
            .child(feed!.id);
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

    await _firestore.collection('feeds').doc(feed!.id).update({
      'title': title,
      'description': description,
      'color': selectedColor.value.value.toString(),
      'type': type.toString().split('.').last,
      'private': isPrivate.value,
      'nsfw': isNsfw.value,
      if (smallAvatarUrl != null) 'smallAvatar': smallAvatarUrl,
      if (bigAvatarUrl != null) 'bigAvatar': bigAvatarUrl,
      if (smallAvatarHash != null) 'smallAvatarHash': smallAvatarHash,
      if (bigAvatarHash != null) 'bigAvatarHash': bigAvatarHash,
    });

    feed!
      ..title = title
      ..description = description
      ..color = selectedColor.value
      ..type = type
      ..private = isPrivate.value
      ..nsfw = isNsfw.value
      ..smallAvatar = smallAvatarUrl ?? feed!.smallAvatar
      ..bigAvatar = bigAvatarUrl ?? feed!.bigAvatar
      ..smallAvatarHash = smallAvatarHash ?? feed!.smallAvatarHash
      ..bigAvatarHash = bigAvatarHash ?? feed!.bigAvatarHash;

    final user = _authService.currentUser;
    if (user != null && user.feeds != null) {
      final index = user.feeds!.indexWhere((f) => f.id == feed!.id);
      if (index != -1) user.feeds![index] = feed!;
    }

    if (_profileController != null) {
      final index =
          _profileController!.feeds.indexWhere((f) => f.id == feed!.id);
      if (index != -1) _profileController!.feeds[index] = feed!;
    }

    ToastService.showSuccess('editFeed'.tr);
    return true;
  }

  /// Deletes the current feed. Only available in edit mode.
  Future<bool> deleteFeed(BuildContext context) async {
    if (feed == null || deleting.value) return false;
    final confirmed = await DialogService.confirm(
      context: context,
      title: 'deleteFeed'.tr,
      message: 'deleteFeedConfirmation'.tr,
      okLabel: 'delete'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (!confirmed) return false;

    deleting.value = true;
    try {
      await _firestore.collection('feeds').doc(feed!.id).delete();
      _profileController?.feeds.removeWhere((f) => f.id == feed!.id);
      final user = _authService.currentUser;
      user?.feeds?.removeWhere((f) => f.id == feed!.id);
      ToastService.showSuccess('deleteFeed'.tr);
      return true;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return false;
    } finally {
      deleting.value = false;
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

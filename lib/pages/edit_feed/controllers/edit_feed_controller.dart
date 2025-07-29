import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

import '../../../models/feed.dart';
import '../../../services/auth_service.dart';
import '../../../services/error_service.dart';
import '../../../services/toast_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../util/enums/feed_types.dart';
import '../../../services/dialog_service.dart';

class EditFeedController extends GetxController {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final ProfileController? _profileController;
  late Feed feed;

  EditFeedController({
    FirebaseFirestore? firestore,
    AuthService? authService,
    ProfileController? profileController,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? Get.find<AuthService>(),
        _profileController = profileController ??
            (Get.isRegistered<ProfileController>(tag: 'current')
                ? Get.find<ProfileController>(tag: 'current')
                : null);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeSearchController = TextEditingController();

  final Rx<Color> selectedColor = Rx<Color>(Colors.blue);
  final Rx<FeedType?> selectedType = Rx<FeedType?>(null);
  final RxBool isPrivate = false.obs;
  final RxBool isNsfw = false.obs;
  final RxBool saving = false.obs;
  final RxBool deleting = false.obs;
  final Rx<File?> avatarFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

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
    feed = Get.arguments as Feed;
    titleController.text = feed.title;
    descriptionController.text = feed.description ?? '';
    selectedColor.value = feed.color ?? Colors.blue;
    selectedType.value = feed.type;
    isPrivate.value = feed.private ?? false;
    isNsfw.value = feed.nsfw ?? false;
  }

  Future<bool> save() async {
    if (saving.value) return false;

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

    saving.value = true;
    try {
      String? smallAvatarUrl;
      String? bigAvatarUrl;
      if (avatarFile.value != null) {
        final file = avatarFile.value!;
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final small = img.copyResizeCropSquare(decoded, size: 32);
          final big = img.copyResizeCropSquare(decoded, size: 128);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('feed_avatars')
              .child(feed.id);
          final smallRef = storageRef.child('small_avatar.jpg');
          final bigRef = storageRef.child('big_avatar.jpg');
          await smallRef.putData(Uint8List.fromList(img.encodeJpg(small)),
              SettableMetadata(contentType: 'image/jpeg'));
          await bigRef.putData(Uint8List.fromList(img.encodeJpg(big)),
              SettableMetadata(contentType: 'image/jpeg'));
          smallAvatarUrl = await smallRef.getDownloadURL();
          bigAvatarUrl = await bigRef.getDownloadURL();
        }
      }

      await _firestore.collection('feeds').doc(feed.id).update({
        'title': title,
        'description': description,
        'color': selectedColor.value.value.toString(),
        'type': type.toString().split('.').last,
        'private': isPrivate.value,
        'nsfw': isNsfw.value,
        if (smallAvatarUrl != null) 'smallAvatar': smallAvatarUrl,
        if (bigAvatarUrl != null) 'bigAvatar': bigAvatarUrl,
      });

      feed
        ..title = title
        ..description = description
        ..color = selectedColor.value
        ..type = type
        ..private = isPrivate.value
        ..nsfw = isNsfw.value
        ..smallAvatar = smallAvatarUrl ?? feed.smallAvatar
        ..bigAvatar = bigAvatarUrl ?? feed.bigAvatar;

      final user = _authService.currentUser;
      if (user != null && user.feeds != null) {
        final index = user.feeds!.indexWhere((f) => f.id == feed.id);
        if (index != -1) user.feeds![index] = feed;
      }

      if (_profileController != null) {
        final index =
            _profileController!.feeds.indexWhere((f) => f.id == feed.id);
        if (index != -1) _profileController!.feeds[index] = feed;
      }

      ToastService.showSuccess('editFeed'.tr);
      return true;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return false;
    } finally {
      saving.value = false;
    }
  }

  Future<bool> deleteFeed(BuildContext context) async {
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
      await _firestore.collection('feeds').doc(feed.id).delete();
      _profileController?.feeds.removeWhere((f) => f.id == feed.id);
      final user = _authService.currentUser;
      user?.feeds?.removeWhere((f) => f.id == feed.id);
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

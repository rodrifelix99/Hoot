import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            (Get.isRegistered<ProfileController>()
                ? Get.find<ProfileController>()
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

  /// Whether a feed is currently being created.
  final RxBool creating = false.obs;

  /// Creates the feed in Firestore after validating input.
  Future<bool> createFeed() async {
    if (creating.value) return false;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final type = selectedType.value;

    if (title.isEmpty) {
      ToastService.showError('title'.tr);
      return false;
    }
    if (type == null) {
      ToastService.showError('genre'.tr);
      return false;
    }

    creating.value = true;
    try {
      final doc = await _firestore.collection('feeds').add({
        'title': title,
        'description': description,
        'color': selectedColor.value.value.toString(),
        'type': type.toString().split('.').last,
        'private': isPrivate.value,
        'nsfw': isNsfw.value,
        'userId': _userId,
        'imageUrl': _authService.currentUser?.smallProfilePictureUrl,
        'subscriberCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('subscriptions')
          .doc(doc.id)
          .set({'createdAt': FieldValue.serverTimestamp()});
      final feed = Feed(
        id: doc.id,
        userId: _userId,
        imageUrl: _authService.currentUser?.smallProfilePictureUrl,
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
    super.onClose();
  }
}

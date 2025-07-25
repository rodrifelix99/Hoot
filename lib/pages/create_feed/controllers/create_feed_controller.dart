import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/toast_service.dart';
import '../../../services/error_service.dart';
import '../../../util/enums/feed_types.dart';

/// Controller handling the create feed form.
class CreateFeedController extends GetxController {
  final FirebaseFirestore _firestore;
  final String _userId;

  CreateFeedController({FirebaseFirestore? firestore, String? userId})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Controllers for title and description fields.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  /// Selected feed color.
  final Rx<Color> selectedColor = Colors.blue.obs;

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
      await _firestore.collection('feeds').add({
        'title': title,
        'description': description,
        'color': selectedColor.value.value.toString(),
        'type': type.toString().split('.').last,
        'private': isPrivate.value,
        'nsfw': isNsfw.value,
        'userId': _userId,
        'subscriberCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
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

import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';

import '../../../models/feed.dart';
import '../../../services/error_service.dart';
import '../../../services/toast_service.dart';

/// Manages state for creating a new post.
class CreatePostController extends GetxController {
  final FirebaseFirestore _firestore;
  final String _userId;

  CreatePostController({FirebaseFirestore? firestore, String? userId})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Text entered by the user.
  final textController = TextEditingController();

  /// Picked image file.
  final Rx<File?> imageFile = Rx<File?>(null);

  /// Selected GIF url from Tenor.
  final Rx<String?> gifUrl = Rx<String?>(null);

  /// Feed chosen to post to.
  final Rx<Feed?> selectedFeed = Rx<Feed?>(null);

  /// Feeds available to the user.
  final RxList<Feed> availableFeeds = <Feed>[].obs;

  /// Whether a post is currently being published.
  final RxBool publishing = false.obs;

  final _picker = ImagePicker();

  /// Picks an image from the gallery.
  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile.value = File(picked.path);
      gifUrl.value = null;
    }
  }

  /// Opens the Tenor GIF picker bottom sheet.
  Future<void> pickGif(BuildContext context) async {
    final tenor = await TenorGifPickerPage.showAsBottomSheet(context);
    if (tenor != null) {
      gifUrl.value =
          tenor.mediaFormats['gif']?.url ?? tenor.mediaFormats.values.first.url;
      imageFile.value = null;
    }
  }

  /// Extracts the first url from [text].
  String? _firstUrl(String text) {
    final match = RegExp(r'(https?:\/\/\S+)').firstMatch(text);
    return match?.group(0);
  }

  /// Returns the first URL in the current text field, if any.
  String? get linkUrl => _firstUrl(textController.text);

  /// Publishes the post to Firestore after validating the form.
  Future<bool> publish() async {
    if (publishing.value) return false;

    final feed = selectedFeed.value;
    final text = textController.text.trim();

    if (feed == null) {
      ToastService.showError('selectFeed'.tr);
      return false;
    }
    if (text.isEmpty && imageFile.value == null && gifUrl.value == null) {
      ToastService.showError('writeSomething'.tr);
      return false;
    }
    if (text.length > 280) {
      ToastService.showError('youAreGoingTooFast'.tr);
      return false;
    }

    publishing.value = true;
    try {
      await _firestore.collection('posts').add({
        'text': text,
        'feedId': feed.id,
        if (imageFile.value != null) 'images': [imageFile.value!.path],
        if (gifUrl.value != null) 'gifs': [gifUrl.value],
        'userId': _userId,
        'url': _firstUrl(text),
        'createdAt': FieldValue.serverTimestamp(),
      });
      textController.clear();
      imageFile.value = null;
      gifUrl.value = null;
      return true;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return false;
    } finally {
      publishing.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

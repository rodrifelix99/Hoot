import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/feed.dart';
import '../../../services/error_service.dart';
import '../../../services/toast_service.dart';
import '../../../services/post_service.dart';
import '../../../services/auth_service.dart';

/// Manages state for creating a new post.
class CreatePostController extends GetxController {
  final BasePostService _postService;
  final AuthService _authService;
  final String _userId;

  CreatePostController({
    BasePostService? postService,
    AuthService? authService,
    String? userId,
  })  : _postService = postService ?? PostService(),
        _authService = authService ?? Get.find<AuthService>(),
        _userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Text entered by the user.
  final textController = TextEditingController();

  /// Picked image files, up to 4.
  final RxList<File> imageFiles = <File>[].obs;

  /// Selected GIF url from Tenor.
  final Rx<String?> gifUrl = Rx<String?>(null);

  /// Feed chosen to post to.
  final Rx<Feed?> selectedFeed = Rx<Feed?>(null);

  /// Feeds available to the user.
  final RxList<Feed> availableFeeds = <Feed>[].obs;

  /// Whether a post is currently being published.
  final RxBool publishing = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    final user = await _authService.fetchUser();
    availableFeeds.assignAll(user?.feeds ?? []);
  }

  /// Picks an image from the gallery.
  Future<void> pickImage() async {
    final picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      final remaining = 4 - imageFiles.length;
      imageFiles.addAll(picked.take(remaining).map((e) => File(e.path)));
      gifUrl.value = null;
    }
  }

  /// Picks a GIF using the Tenor API.
  void pickGif(String url) async {
    gifUrl.value = url;
    imageFiles.clear();
  }

  /// Removes the image at [index].
  void removeImage(int index) {
    if (index >= 0 && index < imageFiles.length) {
      imageFiles.removeAt(index);
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
    if (text.isEmpty && imageFiles.isEmpty && gifUrl.value == null) {
      ToastService.showError('writeSomething'.tr);
      return false;
    }
    if (text.length > 280) {
      ToastService.showError('youAreGoingTooFast'.tr);
      return false;
    }

    publishing.value = true;
    try {
      final user = _authService.currentUser;
      final feedData = feed.toJson();
      feedData['id'] = feed.id;
      feedData['userId'] = feed.userId;

      final userData = user?.toJson();
      if (userData != null) {
        userData['uid'] = user!.uid;
      }

      await _postService.createPost({
        'text': text,
        'feedId': feed.id,
        'feed': feedData,
        if (imageFiles.isNotEmpty)
          'images': imageFiles.map((f) => f.path).toList(),
        if (gifUrl.value != null) 'gifs': [gifUrl.value],
        'userId': _userId,
        if (userData != null) 'user': userData,
        'url': _firstUrl(text),
        'createdAt': FieldValue.serverTimestamp(),
      }..removeWhere((key, value) => value == null));
      textController.clear();
      imageFiles.clear();
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

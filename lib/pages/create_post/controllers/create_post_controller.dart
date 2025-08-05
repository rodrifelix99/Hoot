import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/storage_service.dart';
import 'package:hoot/services/user_service.dart';
import 'package:hoot/services/news_service.dart';
import 'package:hoot/util/enums/feed_types.dart';

/// Manages state for creating a new post.
class CreatePostController extends GetxController {
  final BasePostService _postService;
  final AuthService _authService;
  final BaseStorageService _storageService;
  BaseUserService? _userService;
  final BaseNewsService _newsService;
  late final String _userId;

  CreatePostController({
    BasePostService? postService,
    AuthService? authService,
    String? userId,
    BaseStorageService? storageService,
    BaseUserService? userService,
    BaseNewsService? newsService,
  })  : _postService = postService ?? PostService(),
        _authService = authService ?? Get.find<AuthService>(),
        _storageService = storageService ?? StorageService(),
        _userService = userService,
        _newsService = newsService ?? Get.find<BaseNewsService>() {
    _userId = userId ?? _authService.currentUser?.uid ?? '';
  }

  /// Text entered by the user.
  final textController = TextEditingController();

  /// Controller for mention text field.
  final GlobalKey<FlutterMentionsState> mentionKey =
      GlobalKey<FlutterMentionsState>();

  /// Mention suggestions for the text field.
  final RxList<Map<String, dynamic>> mentionSuggestions =
      <Map<String, dynamic>>[].obs;

  /// Picked image files, up to 4.
  final RxList<File> imageFiles = <File>[].obs;

  /// Selected GIF url from Tenor.
  final Rx<String?> gifUrl = Rx<String?>(null);

  /// First URL found in the post text.
  final RxnString linkUrl = RxnString();

  /// Location selected for the post.
  final RxnString location = RxnString();

  /// Feeds chosen to post to.
  final RxList<Feed> selectedFeeds = <Feed>[].obs;

  /// Feeds available to the user.
  final RxList<Feed> availableFeeds = <Feed>[].obs;

  /// Trending news articles.
  final RxList<NewsItem> trendingNews = <NewsItem>[].obs;

  /// Whether a post is currently being published.
  final RxBool publishing = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadFeeds();
    _loadTrendingNews();
    ever<List<Feed>>(selectedFeeds, (feeds) {
      final topic = feeds.isNotEmpty ? feeds.last.type?.rssTopic : null;
      _loadTrendingNews(topic: topic);
    });
  }

  Future<void> _loadFeeds() async {
    final user = await _authService.fetchUser();
    availableFeeds.assignAll(user?.feeds ?? []);
  }

  Future<void> _loadTrendingNews({String? topic}) async {
    try {
      var news = await _newsService.fetchTrendingNews(topic: topic);
      if (news.isEmpty && topic != null) {
        news = await _newsService.fetchTrendingNews();
      }
      trendingNews.assignAll(news);
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      if (topic != null) {
        try {
          final fallback = await _newsService.fetchTrendingNews();
          trendingNews.assignAll(fallback);
        } catch (e2, s2) {
          await ErrorService.reportError(e2, stack: s2);
        }
      }
    }
  }

  /// Toggles the post location using the device's current position.
  Future<void> toggleLocation() async {
    if (location.value != null) {
      location.value = null;
      return;
    }
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ToastService.showError('couldNotGetLocation'.tr);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality;
        final country = place.country;
        if (city != null && city.isNotEmpty && country != null && country.isNotEmpty) {
          location.value = '$city, $country';
        }
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      ToastService.showError('couldNotGetLocation'.tr);
    }
  }

  /// Searches users for the mention field.
  Future<void> searchUsers(String query) async {
    _userService ??= UserService();
    final users = await _authService.searchUsers(query);
    mentionSuggestions.assignAll(users.map((u) => {
          'id': u.uid,
          'display': u.username ?? '',
          'photo': u.smallProfilePictureUrl,
        }));
  }

  /// Picks an image from the gallery.
  Future<void> pickImage() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
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

  /// Crops the image at [index] using the `image_cropper` package.
  Future<void> cropImage(int index) async {
    if (index < 0 || index >= imageFiles.length) return;
    final file = imageFiles[index];
    final cropped = await ImageCropper().cropImage(sourcePath: file.path);
    if (cropped != null) {
      imageFiles[index] = File(cropped.path);
      imageFiles.refresh();
    }
  }

  /// Extracts the first url from [text].
  String? _firstUrl(String text) {
    final match = RegExp(r'(https?:\/\/\S+)').firstMatch(text);
    return match?.group(0);
  }

  /// Updates [textController] and [linkUrl] when the text changes.
  void onTextChanged(String text) {
    textController.text = text;
    linkUrl.value = _firstUrl(text);
  }

  /// Publishes the post to Firestore after validating the form.
  ///
  /// Returns the newly created [Post] on success or `null` if the post
  /// couldn't be created.
  Future<Post?> publish() async {
    if (publishing.value) return null;

    final feeds = selectedFeeds.toList();
    final text = textController.text.trim();

    if (feeds.isEmpty) {
      ToastService.showError('selectFeed'.tr);
      return null;
    }
    if (text.isEmpty && imageFiles.isEmpty && gifUrl.value == null) {
      ToastService.showError('writeSomething'.tr);
      return null;
    }
    if (text.length > 280) {
      ToastService.showError('youAreGoingTooFast'.tr);
      return null;
    }

    publishing.value = true;
    try {
      final user = _authService.currentUser;
      final userData = user?.toJson();
      if (userData != null) {
        userData['uid'] = user!.uid;
      }

      Post? firstPost;
      for (final feed in feeds) {
        final feedData = feed.toJson();
        feedData['id'] = feed.id;
        feedData['userId'] = feed.userId;

        final postId = _postService.newPostId();
        List<String>? imageUrls;
        List<String>? hashes;
        if (imageFiles.isNotEmpty) {
          final uploaded =
              await _storageService.uploadPostImages(postId, imageFiles);
          imageUrls = uploaded.map((e) => e.url).toList();
          hashes = uploaded.map((e) => e.blurHash).toList();
        }

        await _postService.createPost(
            {
              'text': text,
              'feedId': feed.id,
              'feed': feedData,
              if (imageUrls != null) 'images': imageUrls,
              if (hashes != null) 'hashes': hashes,
              if (gifUrl.value != null) 'gifs': [gifUrl.value],
              'userId': _userId,
              if (userData != null) 'user': userData,
              'url': linkUrl.value,
              'location': location.value,
              'createdAt': FieldValue.serverTimestamp(),
            }..removeWhere((key, value) => value == null),
            id: postId);

        final post = Post(
          id: postId,
          text: text.isEmpty ? null : text,
          media: imageUrls ?? (gifUrl.value != null ? [gifUrl.value!] : null),
          url: linkUrl.value,
          location: location.value,
          feedId: feed.id,
          feed: feed,
          user: user,
          liked: false,
          likes: 0,
          reFeeded: false,
          reFeeds: 0,
          comments: 0,
          createdAt: DateTime.now(),
        );

        firstPost ??= post;
      }

      textController.clear();
      mentionKey.currentState?.controller?.clear();
      imageFiles.clear();
      gifUrl.value = null;
      linkUrl.value = null;
      location.value = null;
      selectedFeeds.clear();
      return firstPost;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      return null;
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

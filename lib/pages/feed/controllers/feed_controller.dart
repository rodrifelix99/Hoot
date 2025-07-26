import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/post.dart';
import '../../../services/feed_service.dart';

/// Controller responsible for fetching posts for the feed view.
class FeedController extends GetxController {
  FeedController({BaseFeedService? service})
      : _feedService = service ?? Get.find<BaseFeedService>();

  final BaseFeedService _feedService;

  final RxList<Post> posts = <Post>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString error = RxnString();
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  /// Loads posts from the service and updates the observable list.
  Future<void> loadPosts() async {
    isLoading.value = true;
    error.value = null;
    _lastDoc = null;
    _hasMore = true;
    try {
      final page = await _feedService.fetchSubscribedPosts();
      posts.assignAll(page.posts);
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;
    } catch (e) {
      error.value = 'somethingWentWrong'.tr;
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Failed to load feed posts',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    final page = await _feedService.fetchSubscribedPosts();
    posts.assignAll(page.posts);
    _lastDoc = page.lastDoc;
    _hasMore = page.hasMore;
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !_hasMore) return;
    isLoadingMore.value = true;
    try {
      final page =
          await _feedService.fetchSubscribedPosts(startAfter: _lastDoc);
      posts.addAll(page.posts);
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;
    } finally {
      isLoadingMore.value = false;
    }
  }
}

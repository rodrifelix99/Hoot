import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/feed.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/feed_service.dart';

/// Loads the current user profile data and owned feeds.
class ProfileController extends GetxController {
  final AuthService _authService;
  final BaseFeedService _feedService;

  ProfileController({AuthService? authService, BaseFeedService? feedService})
      : _authService = authService ?? Get.find<AuthService>(),
        _feedService = feedService ?? Get.find<BaseFeedService>();

  final Rxn<U> user = Rxn<U>();
  final RxList<Feed> feeds = <Feed>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt selectedFeedIndex = 0.obs;
  final RxSet<String> subscribedFeedIds = <String>{}.obs;
  final Map<String, DocumentSnapshot?> _feedLastDocs = {};
  final Map<String, bool> _feedHasMore = {};
  String? uid;
  bool get isCurrentUser => uid == null || uid == _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      uid = args;
    } else if (args is Map && args['uid'] is String) {
      uid = args['uid'] as String;
    }
    loadProfile();
  }

  /// Fetches the current user and their feeds from [AuthService].
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final u = isCurrentUser
          ? await _authService.fetchUser()
          : await _authService.fetchUserById(uid!);
      if (u != null) {
        user.value = u;
        feeds.assignAll(u.feeds ?? []);
      }
      if (feeds.isNotEmpty) {
        await loadFeedPosts(feeds.first.id, refresh: true);
      }
      ever<int>(selectedFeedIndex, (i) {
        final feed = feeds[i];
        if (feed.posts == null || feed.posts!.isEmpty) {
          loadFeedPosts(feed.id, refresh: true);
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFeedPosts(
    String feedId, {
    bool refresh = false,
  }) async {
    final feed = feeds.firstWhere((f) => f.id == feedId);
    if (refresh) {
      _feedLastDocs[feedId] = null;
      _feedHasMore[feedId] = true;
      feed.posts = [];
    }
    if (_feedHasMore[feedId] == false) return;
    isLoadingMore.value = true;
    try {
      final page = await _feedService.fetchFeedPosts(
        feedId,
        startAfter: _feedLastDocs[feedId],
      );
      feed.posts = [...(feed.posts ?? []), ...page.posts];
      feeds.refresh();
      _feedLastDocs[feedId] = page.lastDoc;
      _feedHasMore[feedId] = page.hasMore;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshSelectedFeed() async {
    final feedId = feeds[selectedFeedIndex.value].id;
    await loadFeedPosts(feedId, refresh: true);
  }

  Future<void> loadMoreSelectedFeed() async {
    final feedId = feeds[selectedFeedIndex.value].id;
    await loadFeedPosts(feedId);
  }

  /// Toggles subscription state for [feedId].
  void toggleSubscription(String feedId) {
    if (subscribedFeedIds.contains(feedId)) {
      subscribedFeedIds.remove(feedId);
    } else {
      subscribedFeedIds.add(feedId);
    }
  }

  bool isSubscribed(String feedId) => subscribedFeedIds.contains(feedId);
}

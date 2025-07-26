import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../models/feed.dart';
import '../../../models/post.dart';
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
  final RxInt selectedFeedIndex = 0.obs;
  final RxSet<String> subscribedFeedIds = <String>{}.obs;
  final Map<String, PagingState<DocumentSnapshot?, Post>> feedStates = {};
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
        for (final feed in feeds) {
          feedStates[feed.id] = PagingState<DocumentSnapshot?, Post>();
        }
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
    feedStates.putIfAbsent(
        feedId, () => PagingState<DocumentSnapshot?, Post>());
    var state = feedStates[feedId]!;
    if (refresh) {
      state = state.reset();
    }
    if (!state.hasNextPage && !refresh) return;
    feedStates[feedId] = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _feedService.fetchFeedPosts(
        feedId,
        startAfter: state.keys?.last,
      );
      state = feedStates[feedId]!;
      feedStates[feedId] = state.copyWith(
        pages: [...?state.pages, page.posts],
        keys: [...?state.keys, page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
      feed.posts = [...(feed.posts ?? []), ...page.posts];
      feeds.refresh();
    } finally {
      feedStates[feedId] = feedStates[feedId]!.copyWith(isLoading: false);
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

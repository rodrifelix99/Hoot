import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../models/feed.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/feed_service.dart';
import '../../../services/subscription_service.dart';
import '../../../services/error_service.dart';
import '../../../services/feed_request_service.dart';
import '../../../services/toast_service.dart';

/// Loads the current user profile data and owned feeds.
class ProfileController extends GetxController {
  final AuthService _authService;
  final BaseFeedService _feedService;
  final SubscriptionService _subscriptionService;
  final FeedRequestService _feedRequestService;

  ProfileController({
    AuthService? authService,
    BaseFeedService? feedService,
    SubscriptionService? subscriptionService,
    FeedRequestService? feedRequestService,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _feedService = feedService ?? Get.find<BaseFeedService>(),
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>(),
        _feedRequestService =
            feedRequestService ?? Get.find<FeedRequestService>();

  final Rxn<U> user = Rxn<U>();
  final RxList<Feed> feeds = <Feed>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedFeedIndex = 0.obs;
  final RxSet<String> subscribedFeedIds = <String>{}.obs;
  final RxSet<String> requestedFeedIds = <String>{}.obs;
  final Map<String, PagingState<DocumentSnapshot?, Post>> feedStates = {};
  String? uid;
  String? initialFeedId;
  bool get isCurrentUser => uid == null || uid == _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      uid = args;
    } else if (args is Map) {
      if (args['uid'] is String) {
        uid = args['uid'] as String;
      }
      if (args['feedId'] is String) {
        initialFeedId = args['feedId'] as String;
      }
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
      if (!isCurrentUser && _authService.currentUser != null) {
        final subs = await _subscriptionService
            .fetchSubscriptions(_authService.currentUser!.uid);
        subscribedFeedIds.addAll(subs);
        final reqResults = await Future.wait(
            feeds.map((f) => _feedRequestService.exists(f.id, _authService.currentUser!.uid)));
        for (var i = 0; i < feeds.length; i++) {
          if (reqResults[i]) requestedFeedIds.add(feeds[i].id);
        }
      }

      if (feeds.isNotEmpty) {
        selectedFeedIndex.value = 0;
      }
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
  Future<void> toggleSubscription(String feedId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;
    if (requestedFeedIds.contains(feedId)) return;
    final subscribed = subscribedFeedIds.contains(feedId);
    if (subscribed) {
      subscribedFeedIds.remove(feedId);
      try {
        await _subscriptionService.unsubscribe(userId, feedId);
      } catch (e, s) {
        subscribedFeedIds.add(feedId);
        await ErrorService.reportError(e,
            stack: s, message: 'errorUnsubscribing'.tr);
      }
    } else {
      final feed = feeds.firstWhere((f) => f.id == feedId);
      if (feed.private == true) {
        try {
          await _feedRequestService.submit(feedId, userId);
          requestedFeedIds.add(feedId);
          ToastService.showSuccess('requestSent'.tr);
        } catch (e, s) {
          await ErrorService.reportError(e,
              stack: s, message: 'errorRequestingToJoin'.tr);
        }
      } else {
        subscribedFeedIds.add(feedId);
        try {
          await _subscriptionService.subscribe(userId, feedId);
        } catch (e, s) {
          subscribedFeedIds.remove(feedId);
          await ErrorService.reportError(e,
              stack: s, message: 'errorSubscribing'.tr);
        }
      }
    }
  }

  bool isSubscribed(String feedId) => subscribedFeedIds.contains(feedId);
  bool isRequested(String feedId) => requestedFeedIds.contains(feedId);
}

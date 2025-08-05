import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/subscription_manager.dart';
import 'package:hoot/services/dialog_service.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Loads the current user profile data and owned feeds.
class ProfileController extends GetxController {
  final ProfileArgs? args;
  final AuthService _authService = Get.find<AuthService>();
  final FeedService _feedService = Get.find<FeedService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();
  final FeedRequestService _feedRequestService = Get.find<FeedRequestService>();
  final SubscriptionManager _subscriptionManager =
      Get.find<SubscriptionManager>();

  ProfileController({this.args})
      : uid = args?.uid,
        initialFeedId = args?.feedId;

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
        final reqResults = await Future.wait(feeds.map((f) =>
            _feedRequestService.exists(f.id, _authService.currentUser!.uid)));
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

  /// Reorders feeds locally and persists the new order.
  Future<void> reorderFeeds(int oldIndex, int newIndex) async {
    if (!isCurrentUser) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final feed = feeds.removeAt(oldIndex);
    feeds.insert(newIndex, feed);
    for (var i = 0; i < feeds.length; i++) {
      feeds[i].order = i;
    }
    user.value?.feeds = feeds.toList();
    await _feedService.updateFeedOrder(feeds);
  }

  /// Toggles subscription state for [feedId].
  Future<void> toggleSubscription(String feedId,
      [BuildContext? context]) async {
    final user = _authService.currentUser;
    if (user == null) return;
    final ctx = context ?? Get.context;
    if (requestedFeedIds.contains(feedId)) {
      if (ctx != null) {
        final confirmed = await DialogService.confirm(
          context: ctx,
          title: 'cancelRequest'.tr,
          message: 'cancelRequestConfirmation'.tr,
          okLabel: 'cancelRequest'.tr,
          cancelLabel: 'cancel'.tr,
        );
        if (!confirmed) return;
      } else {
        return;
      }
    } else if (subscribedFeedIds.contains(feedId)) {
      if (ctx != null) {
        final confirmed = await DialogService.confirm(
          context: ctx,
          title: 'unsubscribe'.tr,
          message: 'unsubscribeConfirmation'.tr,
          okLabel: 'unsubscribe'.tr,
          cancelLabel: 'cancel'.tr,
        );
        if (!confirmed) return;
      }
    }
    try {
      final result = await _subscriptionManager.toggle(feedId, user);
      switch (result) {
        case SubscriptionResult.subscribed:
          subscribedFeedIds.add(feedId);
          break;
        case SubscriptionResult.unsubscribed:
          subscribedFeedIds.remove(feedId);
          requestedFeedIds.remove(feedId);
          break;
        case SubscriptionResult.requested:
          requestedFeedIds.add(feedId);
          ToastService.showSuccess('requestSent'.tr);
          break;
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    }
  }

  Future visitUrl() async {
    final url = user.value?.website;
    if (url == null || url.isEmpty) {
      ToastService.showError('noWebsite'.tr);
      return;
    }
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  bool isSubscribed(String feedId) => subscribedFeedIds.contains(feedId);
  bool isRequested(String feedId) => requestedFeedIds.contains(feedId);
}

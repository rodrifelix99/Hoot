import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_manager.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/dialog_service.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';

class FeedPageController extends GetxController {
  final FeedPageArgs? args;
  final AuthService _authService;
  final FeedService _feedService;
  final SubscriptionService _subscriptionService;
  final FeedRequestService _feedRequestService;
  final SubscriptionManager _subscriptionManager;

  FeedPageController({
    this.args,
    AuthService? authService,
    FeedService? feedService,
    SubscriptionService? subscriptionService,
    FeedRequestService? feedRequestService,
    SubscriptionManager? subscriptionManager,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _feedService = feedService ?? Get.find<FeedService>(),
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>(),
        _feedRequestService =
            feedRequestService ?? Get.find<FeedRequestService>(),
        _subscriptionManager =
            subscriptionManager ?? Get.find<SubscriptionManager>();

  final Rxn<Feed> feed = Rxn<Feed>();
  final RxBool loading = false.obs;
  final Rx<PagingState<DocumentSnapshot?, Post>> state =
      PagingState<DocumentSnapshot?, Post>().obs;
  final RxBool subscribed = false.obs;
  final RxBool requested = false.obs;
  final RxBool showNsfwWarning = false.obs;

  bool get isOwner => feed.value?.userId == _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    final a = args;
    if (a?.feed != null) {
      feed.value = a!.feed;
      _initState();
    } else if (a?.feedId != null) {
      _loadFeed(a!.feedId!);
    }
  }

  Future<void> _loadFeed(String id) async {
    loading.value = true;
    final doc =
        await FirebaseFirestore.instance.collection('feeds').doc(id).get();
    if (doc.exists) {
      feed.value = Feed.fromJson({'id': doc.id, ...doc.data()!});
    }
    loading.value = false;
    await _initState();
  }

  Future<void> _initState() async {
    final current = _authService.currentUser;
    final f = feed.value;
    if (current != null && f != null && current.uid != f.userId) {
      final subs = await _subscriptionService.fetchSubscriptions(current.uid);
      subscribed.value = subs.contains(f.id);
      final exists = await _feedRequestService.exists(f.id, current.uid);
      requested.value = exists;
    }
    if (f != null && f.nsfw == true && f.private != true && !subscribed.value) {
      showNsfwWarning.value = true;
    } else {
      fetchNext();
    }
  }

  Future<void> fetchNext() async {
    if (state.value.isLoading || feed.value == null) return;
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final page = await _feedService.fetchFeedPosts(
        feed.value!.id,
        startAfter: state.value.keys?.last,
      );
      state.value = state.value.copyWith(
        pages: [...?state.value.pages, page.posts],
        keys: [...?state.value.keys, page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
    } catch (e, s) {
      state.value = state.value.copyWith(error: e, isLoading: false);
      await ErrorService.reportError(e, stack: s);
    }
  }

  Future<void> refreshFeed() async {
    state.value = state.value.reset();
    await fetchNext();
  }

  void acknowledgeNsfw() {
    showNsfwWarning.value = false;
    fetchNext();
  }

  Future<void> toggleSubscription([BuildContext? context]) async {
    final current = _authService.currentUser;
    final f = feed.value;
    if (current == null || f == null) return;
    final ctx = context ?? Get.context;
    if (requested.value) {
      if (ctx != null) {
        final confirmed = await DialogService.confirm(
          context: ctx,
          title: 'cancelRequest'.tr,
          message: 'cancelRequestConfirmation'.tr,
          okLabel: 'cancelRequest'.tr,
          cancelLabel: 'cancel'.tr,
        );
        if (!confirmed) return;
      }
    } else if (subscribed.value) {
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
      final result = await _subscriptionManager.toggle(f.id, current);
      switch (result) {
        case SubscriptionResult.subscribed:
          subscribed.value = true;
          break;
        case SubscriptionResult.unsubscribed:
          subscribed.value = false;
          requested.value = false;
          break;
        case SubscriptionResult.requested:
          requested.value = true;
          ToastService.showSuccess('requestSent'.tr);
          break;
      }
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
    }
  }
}

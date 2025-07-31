import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../models/feed.dart';
import '../../../models/post.dart';
import '../../../services/auth_service.dart';
import '../../../services/feed_service.dart';
import '../../../services/subscription_service.dart';
import '../../../services/feed_request_service.dart';
import '../../../services/subscription_manager.dart';
import '../../../services/error_service.dart';
import '../../../services/toast_service.dart';

class FeedPageController extends GetxController {
  final AuthService _authService;
  final BaseFeedService _feedService;
  final SubscriptionService _subscriptionService;
  final FeedRequestService _feedRequestService;
  final SubscriptionManager _subscriptionManager;

  FeedPageController({
    AuthService? authService,
    BaseFeedService? feedService,
    SubscriptionService? subscriptionService,
    FeedRequestService? feedRequestService,
    SubscriptionManager? subscriptionManager,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _feedService = feedService ?? Get.find<BaseFeedService>(),
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
    final args = Get.arguments;
    if (args is Feed) {
      feed.value = args;
      _initState();
    } else if (args is Map && args['feed'] is Feed) {
      feed.value = args['feed'];
      _initState();
    } else if (args is String) {
      _loadFeed(args);
    } else if (args is Map && args['id'] is String) {
      _loadFeed(args['id']);
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

  Future<void> toggleSubscription() async {
    final current = _authService.currentUser;
    final f = feed.value;
    if (current == null || f == null) return;
    if (requested.value) return;
    try {
      final result = await _subscriptionManager.toggle(f.id, current);
      switch (result) {
        case SubscriptionResult.subscribed:
          subscribed.value = true;
          break;
        case SubscriptionResult.unsubscribed:
          subscribed.value = false;
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

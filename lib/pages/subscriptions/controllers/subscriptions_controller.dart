import 'package:get/get.dart';

import '../../../models/feed.dart';
import '../../../services/auth_service.dart';
import '../../../services/subscription_service.dart';

/// Controller that loads the feeds the current user is subscribed to.
class SubscriptionsController extends GetxController {
  final AuthService _authService;
  final SubscriptionService _subscriptionService;

  SubscriptionsController({
    AuthService? authService,
    SubscriptionService? subscriptionService,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>();

  final RxList<Feed> feeds = <Feed>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;
    loading.value = true;
    try {
      final result = await _subscriptionService.fetchSubscribedFeeds(userId);
      feeds.assignAll(
        result.where((f) => f.userId != userId).toList(),
      );
    } finally {
      loading.value = false;
    }
  }

  /// Unsubscribes from [feedId] and updates the local list.
  Future<void> unsubscribeFeed(String feedId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;
    await _subscriptionService.unsubscribe(userId, feedId);
    feeds.removeWhere((f) => f.id == feedId);
  }
}

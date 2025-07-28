import 'package:get/get.dart';

import '../../../models/user.dart';
import '../../../services/subscription_service.dart';

class SubscribersController extends GetxController {
  final SubscriptionService _subscriptionService;

  SubscribersController({SubscriptionService? subscriptionService})
      : _subscriptionService =
            subscriptionService ?? Get.find<SubscriptionService>();

  late String feedId;
  final RxList<U> subscribers = <U>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    feedId = Get.arguments as String;
    loadSubscribers();
  }

  Future<void> loadSubscribers() async {
    loading.value = true;
    try {
      final result = await _subscriptionService.fetchSubscribers(feedId);
      subscribers.assignAll(result);
    } finally {
      loading.value = false;
    }
  }

  Future<void> removeSubscriber(String userId) async {
    await _subscriptionService.removeSubscriber(feedId, userId);
    subscribers.removeWhere((u) => u.uid == userId);
  }

  Future<void> banSubscriber(String userId) async {
    await _subscriptionService.banSubscriber(feedId, userId);
    subscribers.removeWhere((u) => u.uid == userId);
  }
}

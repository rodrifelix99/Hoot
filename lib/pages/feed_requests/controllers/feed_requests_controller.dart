import 'package:get/get.dart';

import '../../../models/feed_join_request.dart';
import '../../../services/feed_request_service.dart';
import '../../../util/routes/app_routes.dart';

class FeedRequestsController extends GetxController {
  final FeedRequestService _service;

  FeedRequestsController({FeedRequestService? service})
      : _service = service ?? Get.find<FeedRequestService>();

  late String feedId;
  final RxList<FeedJoinRequest> requests = <FeedJoinRequest>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    feedId = Get.arguments as String;
    loadRequests();
  }

  Future<void> loadRequests() async {
    loading.value = true;
    try {
      final result = await _service.fetchRequests(feedId);
      requests.assignAll(result);
    } finally {
      loading.value = false;
    }
  }

  Future<void> accept(String userId) async {
    await _service.accept(feedId, userId);
    requests.removeWhere((r) => r.user.uid == userId);
  }

  Future<void> reject(String userId) async {
    await _service.reject(feedId, userId);
    requests.removeWhere((r) => r.user.uid == userId);
  }

  void openProfile(String userId) {
    Get.toNamed(AppRoutes.profile, arguments: userId);
  }
}

import 'package:get/get.dart';

import 'package:hoot/models/feed_join_request.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/profile_args.dart';

class FeedRequestsController extends GetxController {
  final FeedRequestService _service;
  final AuthService _authService;

  FeedRequestsController(
      {FeedRequestService? service, AuthService? authService})
      : _service = service ?? Get.find<FeedRequestService>(),
        _authService = authService ?? Get.find<AuthService>();

  final RxList<FeedJoinRequest> requests = <FeedJoinRequest>[].obs;
  final RxMap<String, String> feedTitles = <String, String>{}.obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  Future<void> loadRequests() async {
    loading.value = true;
    try {
      final result = await _service.fetchRequestsForMyFeeds();
      requests.assignAll(result);
      final user = await _authService.fetchUser();
      if (user?.feeds != null) {
        feedTitles.assignAll({for (final f in user!.feeds!) f.id: f.title});
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> accept(String feedId, String userId) async {
    await _service.accept(feedId, userId);
    requests.removeWhere((r) => r.user.uid == userId && r.feedId == feedId);
  }

  Future<void> reject(String feedId, String userId) async {
    await _service.reject(feedId, userId);
    requests.removeWhere((r) => r.user.uid == userId && r.feedId == feedId);
  }

  void openProfile(String userId) {
    Get.toNamed(AppRoutes.profile, arguments: ProfileArgs(uid: userId));
  }
}

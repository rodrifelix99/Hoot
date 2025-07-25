import 'package:get/get.dart';

import '../../../models/feed.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';

/// Loads the current user profile data and owned feeds.
class ProfileController extends GetxController {
  final AuthService _authService;

  ProfileController({AuthService? authService})
      : _authService = authService ?? Get.find<AuthService>();

  final Rxn<U> user = Rxn<U>();
  final RxList<Feed> feeds = <Feed>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedFeedIndex = 0.obs;
  final RxSet<String> subscribedFeedIds = <String>{}.obs;
  String? uid;
  bool get isCurrentUser =>
      uid == null || uid == _authService.currentUser?.uid;

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
    } finally {
      isLoading.value = false;
    }
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

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

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Fetches the current user and their feeds from [AuthService].
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final u = await _authService.fetchUser();
      if (u != null) {
        user.value = u;
        feeds.assignAll(u.feeds ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }
}

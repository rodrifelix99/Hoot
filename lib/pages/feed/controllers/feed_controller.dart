import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';

import '../../../models/post.dart';
import '../../../services/feed_service.dart';

/// Controller responsible for fetching posts for the feed view.
class FeedController extends GetxController {
  FeedController({BaseFeedService? service})
      : _feedService = service ?? Get.find<BaseFeedService>();

  final BaseFeedService _feedService;

  final RxList<Post> posts = <Post>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  /// Loads posts from the service and updates the observable list.
  Future<void> loadPosts() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await _feedService.fetchSubscribedPosts();
      posts.assignAll(result);
    } catch (e) {
      error.value = 'somethingWentWrong'.tr;
      FirebaseCrashlytics.instance.recordError(
        e,
        null,
        reason: 'Failed to load feed posts',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

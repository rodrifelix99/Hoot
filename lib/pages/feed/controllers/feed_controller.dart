import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:hoot/models/post.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/error_service.dart';

/// Controller responsible for fetching posts for the feed view.
class FeedController extends GetxController {
  FeedController({BaseFeedService? service})
      : _feedService = service ?? Get.find<BaseFeedService>();

  final BaseFeedService _feedService;

  final Rx<PagingState<DocumentSnapshot?, Post>> state =
      PagingState<DocumentSnapshot?, Post>().obs;

  @override
  void onInit() {
    super.onInit();
    fetchNextPage();
  }

  void fetchNextPage() async {
    final current = state.value;
    if (current.isLoading) return;

    state.value = current.copyWith(isLoading: true, error: null);

    try {
      final page = await _feedService.fetchSubscribedPosts(
        startAfter: current.keys?.last,
      );

      state.value = state.value.copyWith(
        pages: [...?current.pages, page.posts],
        keys: [...?current.keys, page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state.value = state.value.copyWith(error: e, isLoading: false);
      ErrorService.reportError(e, message: 'Failed to load feed posts');
    }
  }

  @override
  void refresh() {
    state.value = state.value.reset();
    fetchNextPage();
  }
}

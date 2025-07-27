import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/post_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post.dart';
import '../controllers/feed_controller.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final state = controller.state.value;
      return PagedListView<DocumentSnapshot?, Post>(
        state: state,
        fetchNextPage: controller.fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, item, index) => PostComponent(post: item),
          firstPageProgressIndicatorBuilder: (_) =>
              const ShimmerListTile(hasSubtitle: true),
          newPageProgressIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          firstPageErrorIndicatorBuilder: (_) => NothingToShowComponent(
            icon: const Icon(Icons.error_outline),
            text: 'somethingWentWrong'.tr,
          ),
          noItemsFoundIndicatorBuilder: (_) => NothingToShowComponent(
            icon: const Icon(Icons.feed_outlined),
            text: 'subscribeToSeeHoots'.tr,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'myFeeds'.tr,
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => controller.refresh()),
        child: _buildBody(context),
      ),
    );
  }
}

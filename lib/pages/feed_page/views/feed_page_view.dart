import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../models/post.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/feed_page_controller.dart';

class FeedPageView extends GetView<FeedPageController> {
  const FeedPageView({super.key});

  Widget _buildHeader(BuildContext context) {
    final feed = controller.feed.value!;
    final color = feed.color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (feed.imageUrl != null && feed.imageUrl!.isNotEmpty)
            ProfileAvatarComponent(
              image: feed.imageUrl!,
              size: 120,
              radius: 32,
            ),
          const SizedBox(height: 8),
          Text(
            feed.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (feed.description != null && feed.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(feed.description!),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.loading.value || controller.feed.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final state = controller.state.value;
      return RefreshIndicator(
        onRefresh: controller.refreshFeed,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            PagedSliverList<DocumentSnapshot?, Post>(
              state: state,
              fetchNextPage: controller.fetchNext,
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, item, index) => PostComponent(post: item),
                firstPageProgressIndicatorBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
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
                  text: 'noPosts'.tr,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SafeArea(child: const SizedBox(height: 32)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final feed = controller.feed.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(feed?.title ?? ''),
          actions: [
            if (controller.isOwner)
              IconButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.editFeed,
                  arguments: feed,
                ),
                icon: const Icon(Icons.edit),
              )
            else if (feed != null)
              IconButton(
                onPressed:
                    controller.requested.value ? null : controller.toggleSubscription,
                icon: Icon(controller.subscribed.value
                    ? Icons.remove
                    : controller.requested.value
                        ? Icons.hourglass_top
                        : Icons.add),
              )
          ],
        ),
        body: _buildBody(context),
      );
    });
  }
}

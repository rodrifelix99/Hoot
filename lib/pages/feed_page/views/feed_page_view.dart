import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../models/post.dart';
import '../../../models/feed.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/feed_page_controller.dart';
import '../../../util/extensions/feed_extension.dart';

class FeedPageView extends GetView<FeedPageController> {
  const FeedPageView({super.key});

  Widget _buildFab(Feed? feed) {
    if (feed == null) return const SizedBox.shrink();
    if (controller.isOwner) {
      return FloatingActionButton(
        heroTag: 'editFeedButton',
        onPressed: () => Get.toNamed(
          AppRoutes.editFeed,
          arguments: feed,
        ),
        child: const Icon(Icons.edit),
      );
    }
    return Obx(() {
      final subscribed = controller.subscribed.value;
      final requested = controller.requested.value;
      IconData icon;
      if (subscribed) {
        icon = Icons.remove;
      } else if (requested) {
        icon = Icons.hourglass_top;
      } else {
        icon = Icons.add;
      }
      return FloatingActionButton(
        heroTag: 'subscribeFeedButton',
        onPressed: requested ? null : controller.toggleSubscription,
        child: Icon(icon),
      );
    });
  }

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
          ProfileAvatarComponent(
            image: feed.bigAvatar ?? '',
            size: 120,
            radius: 32,
            color: feed.color,
            foregroundColor: feed.foregroundColor,
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
          TextButton.icon(
            onPressed: () => Get.toNamed(
              AppRoutes.subscribers,
              arguments: feed.id,
            ),
            icon: const Icon(Icons.group_outlined),
            label: Text('${feed.subscriberCount ?? 0} ${'followers'.tr}'),
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
      final feed = controller.feed.value!;

      // If the feed is private and the current user is not subscribed, show a
      // placeholder instead of the posts.
      if (feed.private == true &&
          !controller.isOwner &&
          !controller.subscribed.value) {
        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              NothingToShowComponent(
                icon: const Icon(Icons.lock_outline),
                text: 'thisFeedIsPrivate'.tr,
                buttonText: controller.requested.value
                    ? 'requested'.tr
                    : 'requestToJoin'.tr,
                buttonAction: controller.requested.value
                    ? null
                    : controller.toggleSubscription,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }

      final state = controller.state.value;
      final body = RefreshIndicator(
        onRefresh: controller.refreshFeed,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            PagedSliverList<DocumentSnapshot?, Post>(
              state: state,
              fetchNextPage: controller.fetchNext,
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, item, index) =>
                    PostComponent(post: item),
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
                  text: 'noHoots'.tr,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SafeArea(child: const SizedBox(height: 32)),
            ),
          ],
        ),
      );

      return Stack(
        children: [
          body,
          if (controller.showNsfwWarning.value)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'nsfwWarning'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: controller.acknowledgeNsfw,
                        child: Text('continueButton'.tr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final feed = controller.feed.value;
      return Scaffold(
        appBar: AppBarComponent(
          title: feed?.title ?? '',
          backgroundColor: feed?.color,
          foregroundColor: feed?.foregroundColor,
        ),
        floatingActionButton: _buildFab(feed),
        body: _buildBody(context),
      );
    });
  }
}

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/pages/feed_page/controllers/feed_page_controller.dart';

class FeedPageView extends GetView<FeedPageController> {
  const FeedPageView({super.key});

  Widget _buildFab(BuildContext context, Feed? feed) {
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
        icon = Icons.close;
      } else {
        icon = Icons.add;
      }
      return FloatingActionButton(
        heroTag: 'subscribeFeedButton',
        onPressed: () => controller.toggleSubscription(context),
        tooltip: subscribed
            ? 'unsubscribe'.tr
            : requested
                ? 'cancelRequest'.tr
                : 'subscribe'.tr,
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
        color: color.withValues(alpha: 0.2),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileAvatarComponent(
              preview: true,
              image: feed.bigAvatar ?? '',
              hash: feed.bigAvatarHash ?? feed.smallAvatarHash,
              size: 120,
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
              label: Text('${feed.subscriberCount ?? 0} ${'subscribers'.tr}'),
            ),
          ],
        ),
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
                imageAsset: 'assets/images/lock.webp',
                text: 'thisFeedIsPrivate'.tr,
                buttonText: controller.requested.value
                    ? 'cancelRequest'.tr
                    : 'requestToJoin'.tr,
                buttonAction: () => controller.toggleSubscription(context),
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
                itemBuilder: (context, item, index) => PostComponent(
                  post: item,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
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
                  imageAsset: 'assets/images/empty.webp',
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      Image.asset(
                        'assets/images/nsfw.webp',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'nsfwWarning'.tr,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.acknowledgeNsfw,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          child: Text('continueButton'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ).frosted(
                blur: 16,
                frostColor: Colors.black,
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
      final showNsfwWarning = controller.showNsfwWarning.value;
      return Scaffold(
        appBar: AppBarComponent(
          title: feed?.title ?? '',
        ),
        extendBodyBehindAppBar: true,
        floatingActionButton:
            !showNsfwWarning ? _buildFab(context, feed) : null,
        body: _buildBody(context),
      );
    });
  }
}

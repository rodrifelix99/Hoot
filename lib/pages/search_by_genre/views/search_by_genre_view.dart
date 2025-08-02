import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/models/feed.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/notification_item.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:hoot/pages/search_by_genre/controllers/search_by_genre_controller.dart';
import 'package:hoot/util/enums/feed_types.dart';

class SearchByGenreView extends GetView<SearchByGenreController> {
  const SearchByGenreView({super.key});

  @override
  Widget build(BuildContext context) {
    final title =
        FeedTypeExtension.toTranslatedString(context, controller.type);
    final emoji = FeedTypeExtension.toEmoji(controller.type);
    return Scaffold(
      appBar: AppBarComponent(
        title: '$emoji $title',
      ),
      body: Obx(() {
        final state = controller.state.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: -8,
              right: -32,
              child: RotatedBox(
                quarterTurns: 3,
                child: Opacity(
                  opacity: 0.25,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 120,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: () => Future.sync(() => controller.refresh()),
              child: PagedListView<DocumentSnapshot?, Feed>(
                state: state,
                fetchNextPage: controller.fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<Feed>(
                  itemBuilder: (context, feed, index) {
                    String content =
                        '${feed.subscriberCount ?? 0} ${'followers'.tr}';
                    if (feed.description != null &&
                        feed.description!.isNotEmpty) {
                      content = '${feed.description}\n$content';
                    }
                    return GestureDetector(
                      onTap: () {
                        HapticService.lightImpact();
                        Get.toNamed(
                          AppRoutes.profile,
                          arguments: ProfileArgs(
                            uid: feed.userId,
                            feedId: feed.id,
                          ),
                        );
                      },
                      child: ListItem(
                        onTap: () {
                          HapticService.lightImpact();
                          Get.toNamed(
                            AppRoutes.feed,
                            arguments: FeedPageArgs(feed: feed),
                          );
                        },
                        avatarUrl: feed.bigAvatar ?? feed.smallAvatar ?? '',
                        avatarHash: feed.bigAvatarHash ?? feed.smallAvatarHash,
                        title: Text(
                          feed.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(content),
                      ),
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
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
                    text: 'searchForGenreFeeds'.trParams({'genre': title}),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

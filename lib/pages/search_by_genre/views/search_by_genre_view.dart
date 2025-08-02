import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/notification_item.dart';
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
      body: Obx(() => Stack(
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
              ListView.builder(
                itemCount: controller.feeds.length,
                itemBuilder: (context, index) {
                  final feed = controller.feeds[index];
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
                        arguments:
                            ProfileArgs(uid: feed.userId, feedId: feed.id),
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
                      title: feed.title,
                      titleStyle: Theme.of(context).textTheme.titleLarge,
                      subtitle: content,
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}

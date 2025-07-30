import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/services/haptic_service.dart';
import '../controllers/search_by_genre_controller.dart';
import '../../../components/list_item_component.dart';
import '../../../components/avatar_component.dart';
import '../../../util/enums/feed_types.dart';
import '../../../util/extensions/feed_extension.dart';

class SearchByGenreView extends GetView<SearchByGenreController> {
  const SearchByGenreView({super.key});

  @override
  Widget build(BuildContext context) {
    final title =
        FeedTypeExtension.toTranslatedString(context, controller.type);

    return Scaffold(
      appBar: AppBarComponent(
        title: title,
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.feeds.length,
            itemBuilder: (context, index) {
              final feed = controller.feeds[index];
              return GestureDetector(
                onTap: () {
                  HapticService.lightImpact();
                  Get.toNamed(
                    AppRoutes.profile,
                    arguments: {'uid': feed.userId, 'feedId': feed.id},
                  );
                },
                child: ListItemComponent(
                  leading: ProfileAvatarComponent(
                    image: feed.bigAvatar ?? '',
                    hash: feed.bigAvatarHash,
                    size: 100,
                    radius: 25,
                    color: feed.color,
                    foregroundColor: feed.foregroundColor,
                  ),
                  title: feed.title,
                  subtitle: '${feed.subscriberCount ?? 0} ${'followers'.tr}',
                ),
              );
            },
          )),
    );
  }
}

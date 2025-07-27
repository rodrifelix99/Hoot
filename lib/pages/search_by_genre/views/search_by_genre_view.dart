import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/search_by_genre_controller.dart';
import '../../../components/list_item_component.dart';
import '../../../components/avatar_component.dart';
import '../../../util/enums/feed_types.dart';

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
              return ListItemComponent(
                leading: ProfileAvatarComponent(
                  image: feed.imageUrl ?? '',
                  size: 100,
                  radius: 25,
                ),
                title: feed.title,
                subtitle: '${feed.subscriberCount ?? 0} ${'followers'.tr}',
              );
            },
          )),
    );
  }
}

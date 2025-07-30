import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';

import '../../../components/avatar_component.dart';
import '../../../components/list_item_component.dart';
import '../../../components/empty_message.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/subscriptions_controller.dart';
import '../../../util/extensions/feed_extension.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'subscriptions'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.feeds.isEmpty) {
          return NothingToShowComponent(
            icon: const Icon(Icons.feed_outlined),
            text: 'noSubscriptions'.tr,
          );
        }
        return ListView.builder(
          itemCount: controller.feeds.length,
          itemBuilder: (context, index) {
            final feed = controller.feeds[index];
            return GestureDetector(
              onTap: () => Get.toNamed(
                AppRoutes.profile,
                arguments: {'uid': feed.userId, 'feedId': feed.id},
              ),
              child: ListItemComponent(
                leading: ProfileAvatarComponent(
                  image: feed.bigAvatar ?? '',
                  size: 100,
                  radius: 25,
                  color: feed.color,
                  foregroundColor: feed.foregroundColor,
                ),
                title: feed.title,
                subtitle:
                    '${feed.subscriberCount ?? 0} ${'followers'.tr}',
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  tooltip: 'unsubscribe'.tr,
                  onPressed: () => controller.unsubscribeFeed(feed.id),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

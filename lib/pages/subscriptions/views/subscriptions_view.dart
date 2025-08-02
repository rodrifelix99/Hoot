import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';

import 'package:hoot/components/notification_item.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:hoot/services/dialog_service.dart';
import 'package:hoot/pages/subscriptions/controllers/subscriptions_controller.dart';

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
          return Center(
            child: NothingToShowComponent(
              icon: const Icon(Icons.feed_outlined),
              text: 'noSubscriptions'.tr,
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.feeds.length,
          itemBuilder: (context, index) {
            final feed = controller.feeds[index];
            return ListItem(
              avatarUrl: feed.bigAvatar ?? '',
              avatarHash: feed.bigAvatarHash ?? feed.smallAvatarHash,
              title: Text(feed.title),
              subtitle: Text('${feed.subscriberCount ?? 0} ${'followers'.tr}'),
              onTap: () {
                HapticService.lightImpact();
                Get.toNamed(
                  AppRoutes.profile,
                  arguments: ProfileArgs(uid: feed.userId, feedId: feed.id),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                tooltip: 'unsubscribe'.tr,
                onPressed: () async {
                  final confirmed = await DialogService.confirm(
                    context: context,
                    title: 'unsubscribe'.tr,
                    message: 'unsubscribeConfirmation'.tr,
                    okLabel: 'unsubscribe'.tr,
                    cancelLabel: 'cancel'.tr,
                  );
                  if (confirmed) {
                    controller.unsubscribeFeed(feed.id);
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }
}

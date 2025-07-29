import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/list_item_component.dart';
import 'package:hoot/util/extensions/datetime_extension.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'notifications'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        Widget list;
        if (controller.notifications.isEmpty) {
          list = Center(
            child: NothingToShowComponent(
              icon: const Icon(SolarIconsBold.bellOff),
              text: 'noNotifications'.tr,
              buttonText: 'refresh'.tr,
              buttonAction: controller.refreshNotifications,
            ),
          );
        } else {
          list = ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final n = controller.notifications[index];
              final user = n.user;
              final feed = n.feed;
              String text;
              switch (n.type) {
                case 0:
                  text = 'userLikedYourHoot'
                      .trParams({'username': user.username ?? ''});
                  break;
                case 1:
                  text = 'newComment'.tr;
                  break;
                case 2:
                  text = 'newMention'.tr;
                  break;
                case 3:
                  text = 'newSubscriber'.trParams({
                    'username': user.username ?? '',
                    'feedName': feed?.title ?? '',
                  });
                  break;
                case 4:
                  text = 'userReFeededYourHoot'
                      .trParams({'username': user.username ?? ''});
                  break;
                default:
                  text = '';
              }
              return GestureDetector(
                onTap: () {
                  switch (n.type) {
                    case 0:
                    case 1:
                    case 2:
                      if (n.postId != null) {
                        Get.toNamed(AppRoutes.post,
                            arguments: {'id': n.postId});
                      }
                      break;
                    case 4:
                      if (n.postId != null) {
                        Get.toNamed(AppRoutes.post,
                            arguments: {'id': n.postId});
                      }
                      break;
                    case 3:
                      Get.toNamed(AppRoutes.profile, arguments: user.uid);
                      break;
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: ListItemComponent(
                    small: true,
                    leadingRadius: 16,
                    leading: GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.profile, arguments: user.uid),
                      child: ProfileAvatarComponent(
                        image: user.largeProfilePictureUrl ?? '',
                        size: 60,
                        radius: 16,
                      ),
                    ),
                    title: text,
                    subtitle: n.createdAt.timeAgo(),
                  ),
                ),
              );
            },
          );
        }
        return Column(
          children: [
            if (controller.requestCount.value > 0)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.feedRequests),
                  child: Text('subscriberRequests'.tr),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: list,
              ),
            ),
          ],
        );
      }),
    );
  }
}

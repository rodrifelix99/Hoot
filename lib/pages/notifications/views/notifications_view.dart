import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/notification_item.dart';
import 'package:hoot/components/avatar_stack.dart';
import 'package:hoot/util/extensions/datetime_extension.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/services/haptic_service.dart';

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
              imageAsset: 'assets/images/notification.webp',
              title: 'noNotifications'.tr,
              text: 'noNotificationsText'.tr,
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
                case 5:
                  text = 'friendJoined'
                      .trParams({'username': user.username ?? ''});
                  break;
                default:
                  text = '';
              }
              return NotificationItem(
                avatarUrl: user.largeProfilePictureUrl ?? '',
                avatarHash: user.bigAvatarHash ?? user.smallAvatarHash,
                title: text,
                subtitle: n.createdAt.timeAgo(),
                onTap: () {
                  HapticService.lightImpact();
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
                      Get.toNamed(
                        AppRoutes.profile,
                        arguments: ProfileArgs(uid: user.uid),
                      );
                      break;
                  }
                },
                onAvatarTap: () {
                  HapticService.lightImpact();
                  Get.toNamed(
                    AppRoutes.profile,
                    arguments: ProfileArgs(uid: user.uid),
                  );
                },
              );
            },
          );
        }
        return Column(
          children: [
            if (controller.requestCount.value > 0)
              ListTile(
                onTap: () => Get.toNamed(AppRoutes.feedRequests),
                title: Text('subscriberRequestsCount'.trParams(
                    {'count': controller.requestCount.value.toString()})),
                leading: AvatarStack(users: controller.requestUsers.toList()),
                trailing: const Icon(Icons.chevron_right),
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

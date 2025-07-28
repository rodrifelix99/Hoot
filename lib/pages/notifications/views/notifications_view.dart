import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
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
          list = NothingToShowComponent(
            icon: const Icon(Icons.notifications_none),
            text: 'noNotifications'.tr,
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
                default:
                  text = '';
              }
              return ListTile(
                leading: ProfileAvatarComponent(
                  image: user.smallProfilePictureUrl ?? '',
                  size: 40,
                  radius: 20,
                ),
                title: Text(text),
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
            Expanded(child: list),
          ],
        );
      }),
    );
  }
}

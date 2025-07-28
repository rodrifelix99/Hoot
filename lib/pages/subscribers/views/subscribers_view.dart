import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscribers_controller.dart';
import '../../../components/avatar_component.dart';
import '../../../components/name_component.dart';
import '../../../components/empty_message.dart';
import '../../../util/routes/app_routes.dart';

class SubscribersView extends GetView<SubscribersController> {
  const SubscribersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('subscribers'.tr),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.subscribers.isEmpty) {
          return NothingToShowComponent(
            icon: const Icon(Icons.person_outline),
            text: 'numberOfSubscribers'.trParams({'count': '0'}),
          );
        }
        return ListView.builder(
          itemCount: controller.subscribers.length,
          itemBuilder: (context, index) {
            final user = controller.subscribers[index];
            return ListTile(
              onTap: () => Get.toNamed(AppRoutes.profile, arguments: user.uid),
              leading: ProfileAvatarComponent(
                image: user.smallProfilePictureUrl ?? '',
                size: 40,
                radius: 20,
              ),
              title: NameComponent(user: user, size: 16),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    controller.removeSubscriber(user.uid);
                  } else if (value == 'ban') {
                    controller.banSubscriber(user.uid);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'remove', child: Text('remove'.tr)),
                  PopupMenuItem(value: 'ban', child: Text('ban'.tr)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

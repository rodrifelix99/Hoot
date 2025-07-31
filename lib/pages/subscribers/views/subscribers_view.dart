import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/subscribers_controller.dart';
import '../../../components/avatar_component.dart';
import '../../../components/name_component.dart';
import '../../../components/empty_message.dart';
import '../../../util/routes/app_routes.dart';
import '../../../services/dialog_service.dart';

class SubscribersView extends GetView<SubscribersController> {
  const SubscribersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'subscribers'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.subscribers.isEmpty) {
          return Center(
            child: NothingToShowComponent(
              icon: const Icon(Icons.person_outline),
              text: 'noSubscribers'.tr,
            ),
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
                hash: user.smallAvatarHash ?? user.bigAvatarHash,
                size: 40,
              ),
              title: NameComponent(user: user, size: 16),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'remove') {
                    final confirmed = await DialogService.confirm(
                      context: context,
                      title: 'removeSubscriber'.tr,
                      message: 'removeSubscriberConfirmation'.tr,
                      okLabel: 'removeSubscriber'.tr,
                      cancelLabel: 'cancel'.tr,
                    );
                    if (confirmed) {
                      controller.removeSubscriber(user.uid);
                    }
                  } else if (value == 'ban') {
                    final confirmed = await DialogService.confirm(
                      context: context,
                      title: 'banSubscriber'.tr,
                      message: 'banSubscriberConfirmation'.tr,
                      okLabel: 'banSubscriber'.tr,
                      cancelLabel: 'cancel'.tr,
                    );
                    if (confirmed) {
                      controller.banSubscriber(user.uid);
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'remove', child: Text('removeSubscriber'.tr)),
                  PopupMenuItem(value: 'ban', child: Text('banSubscriber'.tr)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

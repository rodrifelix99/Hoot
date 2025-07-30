import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/feed_requests_controller.dart';
import '../../../components/avatar_component.dart';
import '../../../components/name_component.dart';
import '../../../components/empty_message.dart';

class FeedRequestsView extends GetView<FeedRequestsController> {
  const FeedRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'feedRequests'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.requests.isEmpty) {
          return NothingToShowComponent(
            icon: const Icon(Icons.person_outline),
            text: 'noRequests'.tr,
          );
        }
        return ListView.builder(
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final user = controller.requests[index];
            return ListTile(
              onTap: () => controller.openProfile(user.uid),
              leading: ProfileAvatarComponent(
                image: user.smallProfilePictureUrl ?? '',
                size: 40,
                radius: 20,
              ),
              title: NameComponent(user: user, size: 16),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'approve'.tr,
                    onPressed: () => controller.accept(user.uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'reject'.tr,
                    onPressed: () => controller.reject(user.uid),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

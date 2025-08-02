import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/feed_requests/controllers/feed_requests_controller.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/notification_item.dart';

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
          return Center(
            child: NothingToShowComponent(
              icon: const Icon(Icons.person_outline),
              text: 'noRequests'.tr,
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final request = controller.requests[index];
            final user = request.user;
            final title =
                controller.feedTitles[request.feedId] ?? request.feedId;
            return ListItem(
              onTap: () => controller.openProfile(user.uid),
              avatarUrl: user.smallProfilePictureUrl ?? '',
              avatarHash: user.smallAvatarHash ?? user.bigAvatarHash,
              title: NameComponent(user: user, size: 16),
              subtitle: Text(title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'approve'.tr,
                    onPressed: () =>
                        controller.accept(request.feedId, user.uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'reject'.tr,
                    onPressed: () =>
                        controller.reject(request.feedId, user.uid),
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

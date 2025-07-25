import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget _buildFeedItem(int index) {
      final feed = controller.feeds[index];
      return ListTile(
        leading: feed.icon != null
            ? Image.network(feed.icon!,
                width: 40, height: 40, fit: BoxFit.cover)
            : const Icon(Icons.feed_outlined),
        title: Text(feed.title),
        subtitle: feed.description != null ? Text(feed.description!) : null,
      );
    }

    Widget _buildBody() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final user = controller.user.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user.bannerPictureUrl != null &&
                user.bannerPictureUrl!.isNotEmpty)
              ImageComponent(
                url: user.bannerPictureUrl!,
                height: 150,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatarComponent(
                    image: user.smallProfilePictureUrl ?? '',
                    size: 80,
                    radius: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NameComponent(
                          user: user,
                          showUsername: true,
                          size: 20,
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(user.bio!),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.editFeed),
                    icon: const Icon(Icons.edit),
                    label: Text('editFeed'.tr),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.subscribers),
                    icon: const Icon(Icons.group),
                    label: Text('subscribers'.tr),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.createPost),
                    icon: const Icon(Icons.add),
                    label: Text('createPost'.tr),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'myFeeds'.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.feeds.length,
              itemBuilder: (_, i) => _buildFeedItem(i),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBarComponent(
        title: 'profile'.tr,
      ),
      body: Obx(_buildBody),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/empty_message.dart';
import '../../../util/routes/app_routes.dart';
import '../../../util/color_utils.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  Widget buildPostItem(int index) {
    final feed = controller.feeds[controller.selectedFeedIndex.value];
    final post = feed.posts?[index];
    if (post == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatarComponent(
                  image: post.user?.smallProfilePictureUrl ?? '',
                  size: 40,
                  radius: 20,
                ),
                const SizedBox(width: 8),
                if (post.user != null)
                  NameComponent(
                    user: post.user!,
                    showUsername: true,
                    size: 16,
                    feedName: post.feed?.title ?? '',
                  ),
              ],
            ),
            if (post.text != null && post.text!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.text!),
            ],
            if (post.media != null && post.media!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ImageComponent(
                url: post.media!.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                radius: 10,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildFeedChips(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          ChoiceChip(
            label: Row(
              children: [
                const Icon(Icons.add, size: 16),
                const SizedBox(width: 4),
                Text('createFeed'.tr),
              ],
            ),
            selected: false,
            onSelected: (_) => Get.toNamed(AppRoutes.createFeed),
          ),
          ...List.generate(controller.feeds.length, (i) {
            final feed = controller.feeds[i];
            final color = feed.color ?? Theme.of(context).colorScheme.primary;
            final textColor = foregroundForBackground(color);
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(
                  feed.title,
                  style: TextStyle(color: textColor),
                ),
                checkmarkColor: textColor,
                selected: controller.selectedFeedIndex.value == i,
                onSelected: (_) => controller.selectedFeedIndex.value = i,
                selectedColor: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget buildBody(BuildContext context) {
    return Obx(() {
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
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'numberOfSubscribers'.trParams({
                              'count': controller.feeds
                                  .fold<int>(
                                      0, (p, f) => p + (f.subscriberCount ?? 0))
                                  .toString()
                            }),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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
            const Divider(height: 32),
            if (controller.feeds.isEmpty)
              NothingToShowComponent(
                icon: const Icon(Icons.feed_outlined),
                text: 'whatIsAFeed'.tr,
                buttonText: 'createFeed'.tr,
                buttonAction: () => Get.toNamed(AppRoutes.createFeed),
              )
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: buildFeedChips(context),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.feeds[controller.selectedFeedIndex.value]
                        .posts?.length ??
                    0,
                itemBuilder: (_, i) => buildPostItem(i),
              ),
            ],
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'profile'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: buildBody(context),
      floatingActionButton: buildEditButton(),
    );
  }

  Widget buildEditButton() {
    return Obx(() {
      final feeds = controller.feeds;
      final user = controller.user.value;
      if (feeds.isEmpty || user == null) return const SizedBox.shrink();
      final feed = feeds[controller.selectedFeedIndex.value];
      if (feed.userId != user.uid) return const SizedBox.shrink();
      return FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.editFeed, arguments: feed),
        tooltip: 'editFeed'.tr,
        child: const Icon(Icons.edit),
      );
    });
  }
}

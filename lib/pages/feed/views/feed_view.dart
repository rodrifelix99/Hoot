import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import '../controllers/feed_controller.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  Widget _buildPost(BuildContext context, int index) {
    final post = controller.posts[index];
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

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerListTile(hasSubtitle: true),
      );
    }

    if (controller.error.value != null) {
      return NothingToShowComponent(
        icon: const Icon(Icons.error_outline),
        text: controller.error.value!,
      );
    }

    if (controller.posts.isEmpty) {
      return NothingToShowComponent(
        icon: const Icon(Icons.feed_outlined),
        text: 'subscribeToSeeHoots'.tr,
      );
    }

    return ListView.builder(
      itemCount: controller.posts.length,
      itemBuilder: _buildPost,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'feed'.tr,
      ),
      body: Obx(() => _buildBody(context)),
    );
  }
}

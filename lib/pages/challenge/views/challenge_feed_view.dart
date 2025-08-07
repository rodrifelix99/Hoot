import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/components/challenge_card.dart';
import 'package:hoot/pages/challenge/challenge_feed_controller.dart';

/// Displays posts tagged with the currently active challenge.
class ChallengeFeedView extends GetView<ChallengeFeedController> {
  const ChallengeFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'challenge'.tr,
      ),
      body: Obx(() {
        if (controller.challengeLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.noActiveChallenge) {
          return Center(
            child: NothingToShowComponent(
              imageAsset: 'assets/images/empty.webp',
              text: 'noActiveChallenge'.tr,
            ),
          );
        }
        if (controller.postsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.postsError.value != null) {
          return Center(
            child: NothingToShowComponent(
              icon: const Icon(Icons.error_outline),
              text: 'somethingWentWrong'.tr,
            ),
          );
        }
        if (controller.posts.isEmpty) {
          return Center(
            child: NothingToShowComponent(
              imageAsset: 'assets/images/empty.webp',
              text: controller.hasAnyPosts.value
                  ? 'challengePostsFiltered'.tr
                  : 'noHoots'.tr,
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.posts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ChallengeCard.withoutActions(
                  challenge: controller.challenge.value!,
                ),
              );
            }
            final post = controller.posts[index - 1];
            return PostComponent(
              post: post,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            );
          },
        );
      }),
    );
  }
}

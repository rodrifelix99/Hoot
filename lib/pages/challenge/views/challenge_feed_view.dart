import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/models/daily_challenge.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/challenge_service.dart';
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
      body: StreamBuilder<DailyChallenge?>(
        stream: Get.find<BaseChallengeService>().watchCurrentChallenge(),
        builder: (context, challengeSnapshot) {
          final challenge = challengeSnapshot.data;
          if (challenge == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('challengeId', isEqualTo: challenge.id)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                FirebaseCrashlytics.instance.recordError(
                  snapshot.error!,
                  snapshot.stackTrace,
                  reason: 'Failed to load challenge posts',
                );
                return Center(
                  child: NothingToShowComponent(
                    icon: const Icon(Icons.error_outline),
                    text: 'somethingWentWrong'.tr,
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: NothingToShowComponent(
                    imageAsset: 'assets/images/empty.webp',
                    text: 'noHoots'.tr,
                  ),
                );
              }
              final posts = docs
                  .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
                  .toList();
              final filtered = controller.filterPosts(posts);
              if (filtered.isEmpty) {
                return NothingToShowComponent(
                  imageAsset: 'assets/images/empty.webp',
                  text: 'challengePostsFiltered'.tr,
                );
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => PostComponent(
                  post: filtered[index],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

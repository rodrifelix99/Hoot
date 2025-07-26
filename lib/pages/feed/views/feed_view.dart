import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post.dart';
import '../controllers/feed_controller.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final FeedController controller = Get.find();

  Widget _buildPost(BuildContext context, Post post) {
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
    return Obx(() {
      final state = controller.state.value;
      return PagedListView<DocumentSnapshot?, Post>(
        state: state,
        fetchNextPage: controller.fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, item, index) => _buildPost(context, item),
          firstPageProgressIndicatorBuilder: (_) =>
              const ShimmerListTile(hasSubtitle: true),
          newPageProgressIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          firstPageErrorIndicatorBuilder: (_) => NothingToShowComponent(
            icon: const Icon(Icons.error_outline),
            text: 'somethingWentWrong'.tr,
          ),
          noItemsFoundIndicatorBuilder: (_) => NothingToShowComponent(
            icon: const Icon(Icons.feed_outlined),
            text: 'subscribeToSeeHoots'.tr,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'feed'.tr,
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => controller.refresh()),
        child: _buildBody(context),
      ),
    );
  }
}

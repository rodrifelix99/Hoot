import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import '../controllers/feed_controller.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final FeedController controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerListTile(hasSubtitle: true),
      );
    }

    if (controller.error.value != null) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          NothingToShowComponent(
            icon: const Icon(Icons.error_outline),
            text: controller.error.value!,
          ),
        ],
      );
    }

    if (controller.posts.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          NothingToShowComponent(
            icon: const Icon(Icons.feed_outlined),
            text: 'subscribeToSeeHoots'.tr,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          controller.posts.length + (controller.isLoadingMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= controller.posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildPost(context, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'feed'.tr,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshPosts,
        child: Obx(() => _buildBody(context)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/post_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/empty_message.dart';
import '../../../util/routes/app_routes.dart';
import '../../../util/color_utils.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController controller = Get.find();

  void reportUser(BuildContext context) {
    final user = controller.user.value;
    if (user == null) return;
    showAdaptiveDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'reportUsername'.trParams({'username': user.username ?? ''}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('done'.tr),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(U user) {
    return Padding(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      child: Column(
        children: [
          if (user.bannerPictureUrl != null &&
              user.bannerPictureUrl!.isNotEmpty)
            ImageComponent(
              url: user.bannerPictureUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              radius: 8,
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileAvatarComponent(
                image: user.largeProfilePictureUrl ?? '',
                size: 80,
                radius: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }

  Widget buildFeedChips(BuildContext context) {
    return Obx(() {
      final List<Widget> chips = [];
      if (controller.isCurrentUser) {
        chips.add(ChoiceChip(
          label: Row(
            children: [
              const Icon(Icons.add, size: 16),
              const SizedBox(width: 4),
              Text('createFeed'.tr),
            ],
          ),
          selected: false,
          onSelected: (_) => Get.toNamed(AppRoutes.createFeed),
        ));
      }

      chips.addAll(List.generate(controller.feeds.length, (i) {
        final feed = controller.feeds[i];
        final color = feed.color ?? Theme.of(context).colorScheme.primary;
        final textColor = foregroundForBackground(color);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChoiceChip(
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
            const SizedBox(width: 4),
            controller.isCurrentUser
                ? IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () =>
                        Get.toNamed(AppRoutes.editFeed, arguments: feed),
                  )
                : TextButton(
                    child: Text(controller.isSubscribed(feed.id)
                        ? 'unsubscribe'.tr
                        : 'subscribe'.tr),
                    onPressed: () => controller.toggleSubscription(feed.id),
                  ),
          ],
        );
      }));

      return Wrap(spacing: 8, children: chips);
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

      final feedId = controller.feeds.isNotEmpty
          ? controller.feeds[controller.selectedFeedIndex.value].id
          : null;
      final state = feedId != null
          ? controller.feedStates[feedId] ??
              PagingState<DocumentSnapshot?, Post>()
          : PagingState<DocumentSnapshot?, Post>();

      return RefreshIndicator(
        onRefresh: controller.refreshSelectedFeed,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: buildHeader(user)),
            const SliverToBoxAdapter(child: Divider(height: 32)),
            if (controller.feeds.isEmpty)
              SliverToBoxAdapter(
                child: controller.isCurrentUser
                    ? NothingToShowComponent(
                        icon: const Icon(Icons.feed_outlined),
                        text: 'whatIsAFeed'.tr,
                        buttonText: 'createFeed'.tr,
                        buttonAction: () => Get.toNamed(AppRoutes.createFeed),
                      )
                    : NothingToShowComponent(
                        icon: const Icon(Icons.feed_outlined),
                        text: 'noFeeds'.trParams({
                          'username': controller.user.value?.username ?? '',
                        }),
                      ),
              )
            else ...[
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildFeedChips(context),
                ),
              ),
              PagedSliverList<DocumentSnapshot?, Post>(
                state: state,
                fetchNextPage: controller.loadMoreSelectedFeed,
                builderDelegate: PagedChildBuilderDelegate<Post>(
                  itemBuilder: (context, item, index) => PostComponent(
                    post: item,
                  ),
                  firstPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
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
                    text: 'noPosts'.tr,
                  ),
                ),
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
          controller.isCurrentUser
              ? IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                )
              : IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => reportUser(context),
                ),
        ],
      ),
      body: buildBody(context),
    );
  }
}

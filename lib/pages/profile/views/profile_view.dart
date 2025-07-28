import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/post_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';
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
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    String? uid;
    if (args is String) {
      uid = args;
    } else if (args is Map && args['uid'] is String) {
      uid = args['uid'] as String;
    }
    controller = Get.find<ProfileController>(tag: uid ?? 'current');
  }

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
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: Stack(
            children: [
              if (user.bannerPictureUrl != null &&
                  user.bannerPictureUrl!.isNotEmpty)
                ImageComponent(
                  url: user.bannerPictureUrl!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              Positioned(
                top: 264,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ProfileAvatarComponent(
                      image: user.largeProfilePictureUrl ?? '',
                      size: 120,
                      radius: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              NameComponent(
                user: user,
                size: 24,
                showUsername: true,
              ),
              if (user.bio != null && user.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    user.bio!,
                  ),
                ),
            ],
          ),
        ),
      ],
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
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.black.withAlpha(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LiquidGlass(
              settings: LiquidGlassSettings(
                blur: 4,
                glassColor: Theme.of(context).colorScheme.surface.withAlpha(50),
              ),
              shape: LiquidOval(),
              glassContainsChild: false,
              child: controller.isCurrentUser
                  ? IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      onPressed: () => Get.toNamed(AppRoutes.settings),
                    )
                  : IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      color: Colors.white,
                      onPressed: () => reportUser(context),
                    ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: controller.feeds.isEmpty
          ? null
          : Obx(() {
              if (controller.isCurrentUser) {
                return FloatingActionButton.extended(
                  heroTag: 'edit_feed_fab',
                  onPressed: () => Get.toNamed(
                    AppRoutes.editFeed,
                    arguments:
                        controller.feeds[controller.selectedFeedIndex.value],
                  ),
                  icon: const Icon(Icons.edit),
                  label: Text('editFeed'.tr),
                );
              }
              final feedId =
                  controller.feeds[controller.selectedFeedIndex.value].id;
              final subscribed = controller.isSubscribed(feedId);
              return FloatingActionButton.extended(
                heroTag: 'sub_fab',
                onPressed: () => controller.toggleSubscription(feedId),
                icon: Icon(subscribed ? Icons.check : Icons.add),
                label: Text(subscribed ? 'unsubscribe'.tr : 'subscribe'.tr),
              );
            }),
      body: buildBody(context),
    );
  }
}

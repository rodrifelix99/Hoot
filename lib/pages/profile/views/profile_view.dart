import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/extensions/feed_extension.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../models/user.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/empty_message.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../../../services/report_service.dart';
import '../../../services/toast_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

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

  Future<void> reportUser(BuildContext context) async {
    final user = controller.user.value;
    if (user == null) return;
    final reasons = await showTextInputDialog(
      context: context,
      title: 'reportUsername'.trParams({'username': user.username ?? ''}),
      textFields: [
        DialogTextField(
          hintText: 'reportInfo'.tr,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 5,
          minLines: 3,
          maxLength: 500,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'reportReasonRequired'.tr;
            }
            return null;
          }
        )
      ],
    );
    final reason = reasons?.first;
    if (reason == null || reason.isEmpty) return;
    final service = Get.isRegistered<BaseReportService>()
        ? Get.find<BaseReportService>()
        : ReportService();
    try {
      await service.reportUser(userId: user.uid, reason: reason);
      ToastService.showSuccess('reportSent'.tr);
    } catch (_) {
      ToastService.showError('somethingWentWrong'.tr);
    }
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
                      radius: 16,
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

  Widget buildFeedGrid(BuildContext context) {
    return Obx(() {
      final feeds = controller.feeds;
      final itemCount =
          controller.isCurrentUser ? feeds.length + 1 : feeds.length;
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (controller.isCurrentUser && index == 0) {
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.createFeed),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: Center(
                      child: Icon(
                        SolarIconsBold.addSquare,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(75),
                      ),
                    ),
                  ),
                );
              }
              final feed = feeds[controller.isCurrentUser ? index - 1 : index];
              final color = feed.color ?? Theme.of(context).colorScheme.primary;
              final textColor = feed.foregroundColor;
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: feed.bigAvatar ??
                            controller.user.value?.largeProfilePictureUrl ??
                            '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: color.withAlpha(200),
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            AppRoutes.feed,
                            arguments: feed.id,
                          ),
                          splashColor: Colors.white.withAlpha(50),
                          highlightColor: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                feed.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Get.textTheme.titleLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (feed.description != null &&
                                  feed.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  feed.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                '${feed.subscriberCount ?? 0} ${'followers'.tr}',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: itemCount,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
        ),
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

      return RefreshIndicator(
        onRefresh: () async => controller.loadProfile(),
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
            else
              buildFeedGrid(context),
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
            child: LiquidGlassLayer(
              settings: LiquidGlassSettings(
                blur: 4,
                glassColor: Theme.of(context).colorScheme.surface.withAlpha(50),
              ),
              child: Row(
                children: [
                  if (controller.isCurrentUser)
                    LiquidGlass.inLayer(
                      shape: LiquidOval(),
                      glassContainsChild: false,
                      child: IconButton(
                        icon: const Icon(Icons.people_rounded),
                        color: Colors.white,
                        onPressed: () => Get.toNamed(
                          AppRoutes.subscriptions,
                          arguments: controller.user.value?.uid,
                        ),
                      ),
                    ),
                  LiquidGlass.inLayer(
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
                ],
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: buildBody(context),
    );
  }
}

import 'dart:ui';
import 'package:blur/blur.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/extensions/feed_extension.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/services/report_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:hoot/services/haptic_service.dart';

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
    final args = Get.arguments as ProfileArgs?;
    controller = Get.find<ProfileController>(tag: args?.uid ?? 'current');
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
            })
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
    return AspectRatio(
      aspectRatio: 0.7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (user.bannerPictureUrl != null &&
              user.bannerPictureUrl!.isNotEmpty)
            ImageComponent(
              url: user.largeProfilePictureUrl!,
              hash: user.bigAvatarHash,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: double.infinity,
              height: 500,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32).copyWith(
                top: 150,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withAlpha(0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageFilter.isShaderFilterSupported
                      ? Glassify(
                          settings: LiquidGlassSettings(
                            blur: 16,
                            glassColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black54
                                    : Colors.white38,
                          ),
                          child: Text(
                            user.name ?? '',
                            style: Get.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 64,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Text(
                          user.name ?? '',
                          style: Get.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 64,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 8),
                  Text(
                    '@${user.username ?? ''}',
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.bio!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String cleanUpUrl(String url) {
    String uri = url;
    uri = url.replaceAll('www.', '');
    uri = uri.replaceAll('http://', '');
    uri = uri.replaceAll('https://', '');
    uri = uri.replaceAll(RegExp(r'\/$'), ''); // Remove trailing slash
    return uri;
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
                  onTap: () {
                    HapticService.lightImpact();
                    Get.toNamed(AppRoutes.createFeed);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.outline.withAlpha(50),
                        width: 1,
                      ),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          HashCachedImage(
                            imageUrl:
                                controller.user.value?.smallProfilePictureUrl ??
                                    '',
                            hash: controller.user.value?.smallAvatarHash,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ).blurred(
                            blur: 16,
                            blurColor: Theme.of(context).colorScheme.surface,
                            colorOpacity: 0.25,
                          ),
                          Center(
                            child: Icon(
                              SolarIconsBold.addSquare,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(125),
                            ),
                          ),
                        ],
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
                      child: HashCachedImage(
                        imageUrl: feed.smallAvatar ??
                            controller.user.value?.smallProfilePictureUrl ??
                            '',
                        hash: feed.bigAvatarHash ??
                            controller.user.value?.bigAvatarHash,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ).blurred(
                        blur: 16,
                        blurColor: color,
                        colorOpacity: 0.5,
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () {
                            HapticService.lightImpact();
                            Get.toNamed(
                              AppRoutes.feed,
                              arguments: FeedPageArgs(feedId: feed.id),
                            );
                          },
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
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
                child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                if (user.location != null && user.location!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        SolarIconsBold.mapPoint,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location!,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                if (user.website != null && user.website!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      HapticService.lightImpact();
                      controller.visitUrl();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          SolarIconsBold.global,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cleanUpUrl(user.website!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            if (controller.feeds.isEmpty)
              SliverToBoxAdapter(
                child: controller.isCurrentUser
                    ? NothingToShowComponent(
                        imageAsset: 'assets/images/feed.webp',
                        title: 'noFeedsYou'.tr,
                        text: 'whatIsAFeed'.tr,
                        buttonText: 'createFeed'.tr,
                        buttonAction: () => Get.toNamed(AppRoutes.createFeed),
                      )
                    : NothingToShowComponent(
                        imageAsset: 'assets/images/feed.webp',
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
            child: ImageFilter.isShaderFilterSupported
                ? LiquidGlassLayer(
                    settings: LiquidGlassSettings(
                      blur: 4,
                      glassColor:
                          Theme.of(context).colorScheme.surface.withAlpha(50),
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
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.settings),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.flag_outlined),
                                  color: Colors.white,
                                  onPressed: () => reportUser(context),
                                ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      if (controller.isCurrentUser)
                        IconButton(
                          icon: const Icon(Icons.people_rounded),
                          color: Colors.white,
                          onPressed: () => Get.toNamed(
                            AppRoutes.subscriptions,
                            arguments: controller.user.value?.uid,
                          ),
                        ),
                      IconButton(
                        icon: controller.isCurrentUser
                            ? const Icon(Icons.settings)
                            : const Icon(Icons.flag_outlined),
                        color: Colors.white,
                        onPressed: () => controller.isCurrentUser
                            ? Get.toNamed(AppRoutes.settings)
                            : reportUser(context),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: buildBody(context),
    );
  }
}

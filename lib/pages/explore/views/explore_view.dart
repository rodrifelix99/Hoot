import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/feed_card.dart';
import 'package:hoot/components/type_box_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../util/routes/app_routes.dart';
import '../../../util/routes/args/profile_args.dart';
import '../controllers/explore_controller.dart';
import 'package:hoot/services/haptic_service.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildSuggestions() {
      return Obx(() {
        if (controller.query.value.isEmpty) return const SizedBox();
        if (controller.searching.value) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controller.userSuggestions.map(
              (u) => ListTile(
                title: Text(u.name ?? ''),
                subtitle: Text('@${u.username ?? ''}'),
                onTap: () => Get.toNamed(
                  AppRoutes.profile,
                  arguments: ProfileArgs(uid: u.uid),
                ),
              ),
            ),
            ...controller.feedSuggestions.map(
              (f) => ListTile(
                leading: ProfileAvatarComponent(
                  image: f.smallAvatar ?? f.bigAvatar ?? '',
                  hash: f.smallAvatarHash ?? f.bigAvatarHash,
                  size: 40,
                ),
                title: Text(f.title),
                subtitle: Text('feed'.tr),
                onTap: () => Get.toNamed(
                  AppRoutes.profile,
                  arguments: ProfileArgs(uid: f.userId, feedId: f.id),
                ),
              ),
            ),
          ],
        );
      });
    }

    return Scaffold(
      appBar: AppBarComponent(
        title: 'explore'.tr,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshExplore,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'searchPlaceholder'.tr,
                    prefixIcon: const Icon(SolarIconsOutline.magnifier),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.search,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: buildSuggestions(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'popularUsers'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: controller.popularUsers.length,
                    itemBuilder: (context, index) {
                      final u = controller.popularUsers[index];
                      return GestureDetector(
                        onTap: () {
                          HapticService.lightImpact();
                          Get.toNamed(
                            AppRoutes.profile,
                            arguments: ProfileArgs(uid: u.uid),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ProfileAvatarComponent(
                            image: u.largeProfilePictureUrl ?? '',
                            hash: u.bigAvatarHash ?? u.smallAvatarHash,
                            size: 80,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 42),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'top10MostSubscribed'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: 200,
                child: Obx(
                  () => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.topFeeds.length,
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final feed = controller.topFeeds[index];
                      return FeedCard(feed: feed, onTap: () {
                        Get.toNamed(
                          AppRoutes.feed,
                          arguments: FeedPageArgs(feed: feed),
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'popularTypes'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: 200,
                child: Obx(() => ListView.separated(
                      padding: const EdgeInsets.all(16),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.genres.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final type = controller.genres[index];
                        return GestureDetector(
                          onTap: () {
                            HapticService.lightImpact();
                            Get.toNamed(
                              AppRoutes.searchByGenre,
                              arguments: type,
                            );
                          },
                          child: TypeBoxComponent(type: type),
                        );
                      },
                    )),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'top10RecentPopularHoots'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.topPosts.length,
                  itemBuilder: (context, index) {
                    final p = controller.topPosts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: PostComponent(
                        post: p,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(child: const SizedBox(height: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

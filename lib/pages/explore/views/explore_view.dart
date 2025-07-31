import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/list_item_component.dart';
import 'package:hoot/components/type_box_component.dart';
import 'package:hoot/util/extensions/feed_extension.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/post_component.dart';
import '../../../util/routes/app_routes.dart';
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
                onTap: () => Get.toNamed(AppRoutes.profile, arguments: u.uid),
              ),
            ),
            ...controller.feedSuggestions.map(
              (f) => ListTile(
                leading: ProfileAvatarComponent(
                  image: f.smallAvatar ?? f.bigAvatar ?? '',
                  hash: f.smallAvatarHash ?? f.bigAvatarHash,
                  size: 40,
                  color: f.color,
                  foregroundColor: f.foregroundColor,
                ),
                title: Text(f.title),
                subtitle: Text('feed'.tr),
                onTap: () => Get.toNamed(
                  AppRoutes.profile,
                  arguments: {'uid': f.userId, 'feedId': f.id},
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
                    prefixIcon: const Icon(Icons.search),
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
              const SizedBox(height: 8),
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
                          Get.toNamed(AppRoutes.profile, arguments: u.uid);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ProfileAvatarComponent(
                            image: u.largeProfilePictureUrl ??
                                '',
                            hash: u.bigAvatarHash ?? u.smallAvatarHash,
                            size: 80,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'top10MostSubscribed'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.topFeeds.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final f = controller.topFeeds[index];
                      return SizedBox(
                        width: 250,
                        child: GestureDetector(
                          onTap: () {
                            HapticService.lightImpact();
                            Get.toNamed(
                              AppRoutes.profile,
                              arguments: {'uid': f.userId, 'feedId': f.id},
                            );
                          },
                          child: ListItemComponent(
                            leading: ProfileAvatarComponent(
                              image: f.bigAvatar ?? '',
                              hash: f.bigAvatarHash ?? f.smallAvatarHash,
                              size: 100,
                              color: f.color,
                              foregroundColor: f.foregroundColor,
                            ),
                            title: f.title,
                            subtitle:
                                '${f.subscriberCount ?? 0} ${'followers'.tr}',
                            backgroundColor: f.color,
                            foregroundColor: f.foregroundColor,
                          ),
                        ),
                      );
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
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: Obx(() => ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'top10RecentPopularHoots'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.topPosts.length,
                  itemBuilder: (context, index) {
                    final p = controller.topPosts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: PostComponent(post: p,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),),
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

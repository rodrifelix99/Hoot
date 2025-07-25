import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/list_item_component.dart';
import 'package:hoot/components/type_box_component.dart';
import '../../../util/enums/feed_types.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget _buildSuggestions() {
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
              ),
            ),
            ...controller.feedSuggestions.map(
              (f) => ListTile(
                title: Text(f.title),
                subtitle: Text('feed'.tr),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'searchPlaceholder'.tr,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: controller.search,
            ),
            const SizedBox(height: 16),
            _buildSuggestions(),
            const SizedBox(height: 16),
            Text('top10MostSubscribed'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: controller.topFeeds
                      .map((f) => ListItemComponent(
                            title: f.title,
                            subtitle:
                                '${f.subscriberCount ?? 0} ${'followers'.tr}',
                          ))
                      .toList(),
                )),
            const SizedBox(height: 16),
            Text('popularTypes'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: Obx(() => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.genres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final type = controller.genres[index];
                      return GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.searchByGenre,
                          arguments: type,
                        ),
                        child: TypeBoxComponent(type: type),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

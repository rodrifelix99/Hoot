import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../explore/views/explore_view.dart';
import '../../feed/views/feed_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const List<Widget> _pages = [
    FeedView(),
    ExploreView(),
    NotificationsView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedIndex.value;
      final unread = Get.find<NotificationsController>().unreadCount.value;
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            Get.toNamed(AppRoutes.createPost);
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: index,
            children: _pages,
          ),
          extendBody: true,
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 8,
            left: MediaQuery.of(context).padding.left + 16,
            right: MediaQuery.of(context).padding.right + 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface.withAlpha(200),
                Theme.of(context).colorScheme.surface.withAlpha(0),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: LiquidGlassLayer(
            settings: LiquidGlassSettings(
              blur: 4,
              glassColor: Theme.of(context).colorScheme.surface.withAlpha(50),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  LiquidGlass.inLayer(
                    shape: LiquidRoundedRectangle(
                      borderRadius: Radius.circular(30),
                    ),
                    glassContainsChild: false,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            SolarIconsOutline.feed,
                            color: index == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => controller.changeIndex(0),
                        ),
                        IconButton(
                          icon: Icon(
                            SolarIconsOutline.compass,
                            color: index == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => controller.changeIndex(1),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Icon(
                                SolarIconsOutline.bell,
                                color: index == 2
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () => controller.changeIndex(2),
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                      minWidth: 16, minHeight: 16),
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      height: 1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            SolarIconsOutline.user,
                            color: index == 3
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => controller.changeIndex(3),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Hero(
                    tag: 'createHootButton',
                    child: LiquidGlass.inLayer(
                      shape: LiquidRoundedRectangle(
                        borderRadius: Radius.circular(30),
                      ),
                      glassContainsChild: false,
                      child: IconButton(
                        icon: Icon(
                          SolarIconsOutline.pen,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.createPost),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),);
    });
  }
}

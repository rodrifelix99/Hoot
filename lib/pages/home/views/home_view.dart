import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../explore/views/explore_view.dart';
import '../../feed/views/feed_view.dart';
import '../../notifications/views/notifications_view.dart';
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
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: _pages,
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 8,
            left: MediaQuery.of(context).padding.left + 16,
            right: MediaQuery.of(context).padding.right + 16,
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
                        IconButton(
                          icon: Icon(
                            SolarIconsOutline.bell,
                            color: index == 2
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => controller.changeIndex(2),
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
        /* Old code:
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.changeIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.transparent,
          indicatorShape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(250),
          destinations: [
            NavigationDestination(
              icon: Icon(
                SolarIconsOutline.feed,
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedIcon: Icon(
                SolarIconsBold.feed,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'feed'.tr,
            ),
            NavigationDestination(
              icon: Icon(
                SolarIconsOutline.compass,
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedIcon: Icon(
                SolarIconsBold.compass,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'explore'.tr,
            ),
            NavigationDestination(
              icon: Icon(
                SolarIconsOutline.addSquare,
                color: Theme.of(context).colorScheme.primary,
                size: 42,
              ),
              selectedIcon: Icon(
                SolarIconsBold.addSquare,
                color: Theme.of(context).colorScheme.primary,
                size: 42,
              ),
              label: 'createPost'.tr,
            ),
            NavigationDestination(
              icon: Icon(
                SolarIconsOutline.bell,
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedIcon: Icon(
                SolarIconsBold.bell,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'notifications'.tr,
            ),
            NavigationDestination(
              icon: Icon(
                SolarIconsOutline.user,
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedIcon: Icon(
                SolarIconsBold.user,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'profile'.tr,
            ),
          ],
        ),*/
      );
    });
  }
}

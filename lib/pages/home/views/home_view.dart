import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../create_post/views/create_post_view.dart';
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
    CreatePostView(),
    NotificationsView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedIndex.value;
      return Scaffold(
        body: _pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.changeIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.transparent,
          indicatorShape: const CircleBorder(),
          destinations: [
            NavigationDestination(
              icon: Icon(SolarIconsOutline.feed),
              selectedIcon: Icon(SolarIconsBold.feed),
              label: 'feed'.tr,
            ),
            NavigationDestination(
              icon: Icon(SolarIconsOutline.compass),
              selectedIcon: Icon(SolarIconsBold.compass),
              label: 'explore'.tr,
            ),
            NavigationDestination(
              icon: Icon(
                SolarIconsOutline.addSquare,
                size: 42,
              ),
              selectedIcon: Icon(
                SolarIconsBold.addSquare,
                size: 42,
              ),
              label: 'createPost'.tr,
            ),
            NavigationDestination(
              icon: Icon(SolarIconsOutline.bell),
              selectedIcon: Icon(SolarIconsBold.bell),
              label: 'notifications'.tr,
            ),
            NavigationDestination(
              icon: Icon(SolarIconsOutline.user),
              selectedIcon: Icon(SolarIconsBold.user),
              label: 'profile'.tr,
            ),
          ],
        ),
      );
    });
  }
}

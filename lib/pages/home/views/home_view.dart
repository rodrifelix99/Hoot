import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.dynamic_feed), label: 'feed'.tr),
            NavigationDestination(
                icon: Icon(Icons.explore), label: 'explore'.tr),
            NavigationDestination(
                icon: Icon(Icons.add), label: 'createPost'.tr),
            NavigationDestination(
                icon: Icon(Icons.notifications), label: 'notifications'.tr),
            NavigationDestination(
                icon: Icon(Icons.person), label: 'profile'.tr),
          ],
        ),
      );
    });
  }
}

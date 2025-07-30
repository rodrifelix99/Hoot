import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_routes.dart';
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
          backgroundColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(controller.screenRadius.value),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: IndexedStack(
              index: index,
              children: _pages,
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 16,
              left: MediaQuery.of(context).padding.left + 16,
              right: MediaQuery.of(context).padding.right + 16,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                iconButtonTheme: IconButtonThemeData(
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primaryFixed,
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,

                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 500),
                    child: IconButton(
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 56,
                      ),
                      icon: Icon(
                        SolarIconsOutline.feed,
                        color: index == 0
                            ? Theme.of(context).colorScheme.primaryFixed
                            : Theme.of(context).colorScheme.primaryFixed.withAlpha(150),
                      ),
                      onPressed: () => controller.changeIndex(0),
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 800),
                    child: IconButton(
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 56,
                      ),
                      icon: Icon(
                        SolarIconsOutline.compass,
                        color: index == 1
                            ? Theme.of(context).colorScheme.primaryFixed
                            : Theme.of(context).colorScheme.primaryFixed.withAlpha(150),
                      ),
                      onPressed: () => controller.changeIndex(1),
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 1100),
                    child: Hero(
                      tag: 'createHootButton',
                      child: IconButton(
                        iconSize: 50,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          SolarIconsBold.addSquare,
                          color: Theme.of(context).colorScheme.primaryFixed.withAlpha(150),
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.createPost),
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 1400),
                        child: IconButton(
                          padding: const EdgeInsets.all(16),
                          constraints: const BoxConstraints(
                            minWidth: 56,
                            minHeight: 56,
                          ),
                          icon: Icon(
                            SolarIconsOutline.bell,
                            color: index == 2
                                ? Theme.of(context).colorScheme.primaryFixed
                                : Theme.of(context).colorScheme.primaryFixed.withAlpha(150),
                          ),
                          onPressed: () => controller.changeIndex(2),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: FadeIn(
                            duration: const Duration(milliseconds: 400),
                            delay: const Duration(milliseconds: 1700),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryFixed,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 16, minHeight: 16),
                              child: Text(
                                unread > 99 ? '' : '$unread',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                                  fontSize: 10,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 1700),
                    child: IconButton(
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 56,
                      ),
                      icon: Icon(
                        SolarIconsOutline.user,
                        color: index == 3
                            ? Theme.of(context).colorScheme.primaryFixed
                            : Theme.of(context).colorScheme.primaryFixed.withAlpha(150),
                      ),
                      onPressed: () => controller.changeIndex(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

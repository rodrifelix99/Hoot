import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/notification_item.dart';
import 'package:hoot/components/avatar_stack.dart';
import 'package:hoot/models/hoot_notification.dart';
import 'package:hoot/util/extensions/datetime_extension.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/services/haptic_service.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'notifications'.tr,
      ),
      extendBodyBehindAppBar: true,
      body: Obx(() {
        final state = controller.state.value;
        return Column(
          children: [
            if (controller.requestCount.value > 0)
              ListTile(
                onTap: () => Get.toNamed(AppRoutes.feedRequests),
                title: Text('subscriberRequestsCount'.trParams(
                    {'count': controller.requestCount.value.toString()})),
                leading: AvatarStack(users: controller.requestUsers.toList()),
                trailing: const Icon(Icons.chevron_right),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: PagedListView<DocumentSnapshot?, HootNotification>(
                  state: state,
                  fetchNextPage: controller.fetchNext,
                  builderDelegate: PagedChildBuilderDelegate<HootNotification>(
                    itemBuilder: (context, n, index) {
                      final user = n.user;
                      final feed = n.feed;
                      String text;
                      switch (n.type) {
                        case 0:
                          text = 'userLikedYourHoot'
                              .trParams({'username': user.username ?? ''});
                          break;
                        case 1:
                          text = 'newComment'.tr;
                          break;
                        case 2:
                          text = 'newMention'.tr;
                          break;
                        case 3:
                          text = 'newSubscriber'.trParams({
                            'username': user.username ?? '',
                            'feedName': feed?.title ?? '',
                          });
                          break;
                        case 4:
                          text = 'userReFeededYourHoot'
                              .trParams({'username': user.username ?? ''});
                          break;
                        case 5:
                          text = 'friendJoined'
                              .trParams({'username': user.username ?? ''});
                          break;
                        case 6:
                          text = 'newReport'.tr;
                          break;
                        default:
                          text = '';
                      }
                      return ListItem(
                        avatarUrl: user.largeProfilePictureUrl ?? '',
                        avatarHash: user.bigAvatarHash ?? user.smallAvatarHash,
                        title: Text(text),
                        subtitle: Text(n.createdAt.timeAgo()),
                        onTap: () {
                          HapticService.lightImpact();
                          switch (n.type) {
                            case 0:
                            case 1:
                            case 2:
                              if (n.postId != null) {
                                Get.toNamed(AppRoutes.post,
                                    arguments: {'id': n.postId});
                              }
                              break;
                            case 3:
                            case 5:
                              Get.toNamed(
                                AppRoutes.profile,
                                arguments: ProfileArgs(uid: user.uid),
                              );
                              break;
                            case 4:
                              if (n.postId != null) {
                                Get.toNamed(AppRoutes.post,
                                    arguments: {'id': n.postId});
                              }
                              break;
                            case 6:
                              Get.toNamed(AppRoutes.staffReports);
                              break;
                          }
                        },
                        onAvatarTap: () {
                          HapticService.lightImpact();
                          Get.toNamed(
                            AppRoutes.profile,
                            arguments: ProfileArgs(uid: user.uid),
                          );
                        },
                      );
                    },
                    firstPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    firstPageErrorIndicatorBuilder: (_) =>
                        NothingToShowComponent(
                      icon: const Icon(Icons.error_outline),
                      text: 'somethingWentWrong'.tr,
                    ),
                    noItemsFoundIndicatorBuilder: (_) => NothingToShowComponent(
                      imageAsset: 'assets/images/notification.webp',
                      title: 'noNotifications'.tr,
                      text: 'noNotificationsText'.tr,
                    ),
                    noMoreItemsIndicatorBuilder: (_) => const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Opacity(
                        opacity: 0.75,
                        child: Center(
                          child: Text('Made in Portugal 🇵🇹'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

import 'package:hoot/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/list_item_component.dart';
import 'package:hoot/models/notification.dart' as Notif;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/error_service.dart';
import 'package:get/get.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import '../app/utils/logger.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late AuthController _authProvider;
  List<Notif.Notification> _notifications = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    super.initState();
    _loadNotifications();
  }

  Future _loadNotifications({DateTime? startAt, bool refresh = false}) async {
    if (startAt == null && !refresh) {
      setState(() => _isLoading = true);
    }
    try {
      List<Notif.Notification> notifications =
          await _authProvider.getNotifications(startAt ?? DateTime.now());
      setState(() {
        _hasMore = notifications.length >= 10;
        startAt != null
            ? _notifications.addAll(notifications)
            : _notifications = notifications;
      });
      _authProvider.markNotificationsAsRead();
    } catch (e) {
      logError(e);
      ToastService.showToast(context, e.toString(), true);
    } finally {
      _refreshController.loadComplete();
      _refreshController.refreshCompleted();
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getNotificationText(Notif.Notification notification) {
    String username = notification.user.username ?? 'User';
    String feedName = notification.feed?.title ?? 'Feed';
    switch (notification.type) {
      case 1:
        return AppLocalizations.of(context)!.newFollower(username);
      case 2:
        return AppLocalizations.of(context)!.newUnfollower(username);
      case 3:
        return AppLocalizations.of(context)!.newSubscriber(feedName, username);
      case 4:
        return AppLocalizations.of(context)!.unsubscriber(feedName, username);
      case 5:
        return AppLocalizations.of(context)!
            .privateFeedRequest(feedName, username);
      case 6:
        return AppLocalizations.of(context)!
            .privateFeedRequestAccepted(feedName, username);
      case 7:
        return AppLocalizations.of(context)!
            .privateFeedRequestRejected(feedName, username);
      case 8:
        return AppLocalizations.of(context)!.userLikedYourHoot(username);
      case 9:
        return AppLocalizations.of(context)!.userReFeededYourHoot(username);
      default:
        return "";
    }
  }

  void _handleNotificationTap(Notif.Notification notification) {
    switch (notification.type) {
      case 1:
      case 2:
      case 3:
      case 4:
        Get.toNamed(context, '/profile', arguments: notification.user);
        break;
      case 6:
      case 7:
        Get.toNamed(context, '/profile',
            arguments: [notification.user, notification.feed?.id]);
        break;
      case 5:
        Get.toNamed(context, '/feed_requests',
            arguments: notification.feed?.id ?? '');
        break;
      case 8:
        Get.toNamed(context, '/post', arguments: [
          _authProvider.user?.uid,
          notification.feed?.id,
          notification.postId
        ]);
      case 9:
        Get.toNamed(context, '/post', arguments: [
          notification.user.uid,
          notification.feed?.id,
          notification.postId
        ]);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: AppLocalizations.of(context)!.notifications,
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const ListItemComponent(
                    leading: SkeletonAvatar(),
                    title: '',
                    subtitle: '',
                    isLoading: true,
                    small: true,
                  ))
          : _notifications.isEmpty
              ? Center(
                  child: NothingToShowComponent(
                      icon: Icon(Icons.notifications_off_rounded),
                      text: AppLocalizations.of(context)!.noNotifications))
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () async =>
                      await _loadNotifications(refresh: true),
                  onLoading: () async => _hasMore
                      ? await _loadNotifications(
                          startAt: _notifications.last.createdAt)
                      : null,
                  physics: const BouncingScrollPhysics(),
                  header: const ClassicHeader(
                    refreshingText: '',
                    idleText: '',
                    completeText: '',
                    releaseText: '',
                  ),
                  footer: const ClassicFooter(
                    failedText: '',
                    idleText: '',
                    loadingText: '',
                    noDataText: '',
                    canLoadingText: '',
                  ),
                  enablePullUp: _hasMore,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () =>
                          _handleNotificationTap(_notifications[index]),
                      child: ListItemComponent(
                        leading: ProfileAvatarComponent(
                            image: _notifications[index]
                                    .user
                                    .smallProfilePictureUrl ??
                                '',
                            size: 50,
                            radius: 15),
                        title: _notifications[index].user.name ??
                            _notifications[index].user.username ??
                            '',
                        small: true,
                        subtitle: _getNotificationText(_notifications[index]),
                        trailing: _notifications[index].read
                            ? Text(
                                timeago.format(_notifications[index].createdAt),
                                style: Theme.of(context).textTheme.bodySmall)
                            : Icon(Icons.circle,
                                color: Theme.of(context).colorScheme.primary),
                      ),
                      /* ListTile(
              onTap: () => _handleNotificationTap(_notifications[index]),
              leading: ProfileAvatarComponent(image: _notifications[index].user.smallProfilePictureUrl ?? '', size: 40),
              title: Text(_notifications[index].user.name ?? _notifications[index].user.username ?? ''),
              subtitle: Text(_getNotificationText(_notifications[index])),
              trailing: _notifications[index].read ? Text(timeago.format(_notifications[index].createdAt)) : Icon(Icons.circle, color: Theme.of(context).colorScheme.primary),
            ) */
                    ),
                  ),
                ),
    );
  }
}

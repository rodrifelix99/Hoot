import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/notification.dart' as Notif;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/error_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late AuthProvider _authProvider;
  List<Notif.Notification> _notifications = [];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    _loadNotifications();
  }

  Future _loadNotifications({DateTime? startAt, bool refresh = false}) async {
    if (startAt == null && !refresh) {
      setState(() => _isLoading = true);
    }
    try {
      List<Notif.Notification> notifications = await _authProvider.getNotifications(startAt ?? DateTime.now());
      setState(() {
        _hasMore = notifications.length >= 10;
        startAt != null ? _notifications.addAll(notifications) : _notifications = notifications;
      });
      _authProvider.markNotificationsAsRead();
    } catch (e) {
      print(e);
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
        return AppLocalizations.of(context)!.privateFeedRequest(feedName, username);
      case 6:
        return AppLocalizations.of(context)!.privateFeedRequestAccepted(feedName, username);
      case 7:
        return AppLocalizations.of(context)!.privateFeedRequestRejected(feedName, username);
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
        Navigator.pushNamed(context, '/profile', arguments: notification.user);
        break;
      case 6:
      case 7:
      Navigator.pushNamed(context, '/profile', arguments: [notification.user, notification.feed?.id]);
      break;
      case 5:
        Navigator.pushNamed(context, '/feed_requests', arguments: notification.feed?.id ?? '');
        break;
      case 8:
        Navigator.pushNamed(context, '/post', arguments: [_authProvider.user?.uid, notification.feed?.id, notification.postId]);
      case 9:
        Navigator.pushNamed(context, '/post', arguments: [notification.user.uid, notification.feed?.id, notification.postId]);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
      ),
      body: _isLoading ? SkeletonListView(
        itemBuilder: (context, index) => SkeletonListTile(
          hasSubtitle: true,
        ),
      ) : _notifications.isEmpty ? Center(
          child: NothingToShowComponent(
              icon: Icon(Icons.notifications_off_rounded),
              text: AppLocalizations.of(context)!.noNotifications
          )
      ) : SmartRefresher(
        controller: _refreshController,
        onRefresh: () async => await _loadNotifications(refresh: true),
        onLoading: () async => _hasMore ? await _loadNotifications(startAt: _notifications.last.createdAt) : null,
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
          itemBuilder: (context, index) => ListTile(
            onTap: () => _handleNotificationTap(_notifications[index]),
            leading: ProfileAvatarComponent(image: _notifications[index].user.smallProfilePictureUrl ?? '', size: 40),
            title: Text(_notifications[index].user.name ?? _notifications[index].user.username ?? ''),
            subtitle: Text(_getNotificationText(_notifications[index])),
            trailing: _notifications[index].read ? Text(timeago.format(_notifications[index].createdAt)) : Icon(Icons.circle, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

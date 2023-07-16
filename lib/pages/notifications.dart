import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/notification.dart' as Notif;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    _loadNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _hasMore ? _loadNotifications(startAt: _notifications.last.createdAt) : null;
      }
    });
  }

  Future _loadNotifications({DateTime? startAt, bool refresh = false}) async {
    if (startAt == null && !refresh) {
      setState(() => _isLoading = true);
    } else if (!refresh) {
      setState(() => _loadingMore = true);
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
      setState(() {
        _isLoading = false;
        _loadingMore = false;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
      ),
      body: _isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : _notifications.isEmpty ? Center(
          child: NothingToShowComponent(
              icon: Icon(Icons.notifications_off_rounded),
              text: AppLocalizations.of(context)!.noNotifications
          )
      ) : Column(
        children: [
          LiquidPullToRefresh(
            onRefresh: () => _loadNotifications(refresh: true),
            showChildOpacityTransition: false,
            color: Theme.of(context).colorScheme.primary,
            child: Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _notifications.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () => _handleNotificationTap(_notifications[index]),
                  leading: ProfileAvatar(image: _notifications[index].user.smallProfilePictureUrl ?? '', size: 40),
                  title: Text(_notifications[index].user.name ?? _notifications[index].user.username ?? ''),
                  subtitle: Text(_getNotificationText(_notifications[index])),
                  trailing: _notifications[index].read ? Text(timeago.format(_notifications[index].createdAt)) : Icon(Icons.circle, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
          _loadingMore ? const Center(
            child: CircularProgressIndicator(),
          ) : Container()
        ],
      ),
    );
  }
}

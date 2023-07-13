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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notif.Notification> _notifications = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _hasMore ? _loadNotifications(startAt: _notifications.last.createdAt) : null;
      }
    });
  }

  Future _loadNotifications({DateTime? startAt}) async {
    if (startAt == null) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      List<Notif.Notification> notifications = await Provider.of<AuthProvider>(context, listen: false).getNotifications(startAt ?? DateTime.now());
      setState(() {
        _hasMore = notifications.length >= 10;
        startAt != null ? _notifications.addAll(notifications) : _notifications = notifications;
      });
      Provider.of<AuthProvider>(context, listen: false).markNotificationsAsRead();
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

  String _getNotificationText(int type, String username) {
    switch (type) {
      case 1:
        return AppLocalizations.of(context)!.newFollower(username);
      case 2:
        return AppLocalizations.of(context)!.newUnfollower(username);
      default:
        return "";
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
      ) : LiquidPullToRefresh(
        onRefresh: () => _loadNotifications(),
        showChildOpacityTransition: false,
        color: Theme.of(context).colorScheme.primary,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _notifications.length,
          itemBuilder: (context, index) => ListTile(
            onTap: () => Navigator.pushNamed(context, '/profile', arguments: _notifications[index].user),
            leading: ProfileAvatar(image: _notifications[index].user.smallProfilePictureUrl ?? '', size: 40),
            title: Text(_notifications[index].user.name ?? _notifications[index].user.username ?? ''),
            subtitle: Text(_getNotificationText(_notifications[index].type, _notifications[index].user.name ?? _notifications[index].user.username ?? '')),
            trailing: _notifications[index].read ? Text(timeago.format(_notifications[index].createdAt)) : Icon(Icons.circle, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

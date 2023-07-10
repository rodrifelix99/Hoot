import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/notification.dart' as Notif;
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
  List<Notif.Notification> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Notif.Notification> notifications = await Provider.of<AuthProvider>(context, listen: false).getNotifications();
      setState(() {
        _notifications = notifications;
      });
      Provider.of<AuthProvider>(context, listen: false).markNotificationsAsRead();
    } catch (e) {
      print(e);
      ToastService.showToast(context, e.toString(), true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getNotificationText(int type) {
    switch (type) {
      case 1:
        return "followed you";
      case 2:
        return "unfollowed you";
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
      ) : _notifications.isEmpty ? const Center(
          child: NothingToShowComponent(
              icon: Icon(Icons.notifications_off_rounded),
              text: "You have no notifications yet"
          )
      ) : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) => ListTile(
          onTap: () => Navigator.pushNamed(context, '/profile', arguments: _notifications[index].user),
          leading: ProfileAvatar(image: _notifications[index].user.smallProfilePictureUrl ?? '', size: 40),
          title: Text(_notifications[index].user.name!),
          subtitle: Text(_getNotificationText(_notifications[index].type)),
          trailing: _notifications[index].read ? Text(timeago.format(_notifications[index].createdAt)) : Icon(Icons.circle, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

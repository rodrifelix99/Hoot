import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:hoot/components/notification_item.dart';

class NotificationsMockTab extends StatefulWidget {
  final bool isActive;
  final VoidCallback onClearUnread;

  const NotificationsMockTab({
    super.key,
    required this.isActive,
    required this.onClearUnread,
  });

  @override
  State<NotificationsMockTab> createState() => _NotificationsMockTabState();
}

class _NotificationsMockTabState extends State<NotificationsMockTab> {
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final jsonString =
        await rootBundle.loadString('mock/data/sample_notifications.json');
    final data = json.decode(jsonString) as List<dynamic>;
    setState(() {
      notifications = data;
    });
  }

  @override
  void didUpdateWidget(covariant NotificationsMockTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      widget.onClearUnread();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final n = notifications[index] as Map<String, dynamic>;
        final user = n['user'] as Map<String, dynamic>? ?? {};
        return ListItem(
          avatarUrl: user['avatarUrl'] ?? '',
          title: Text(n['text'] ?? ''),
          subtitle: Text(n['timestamp'] ?? ''),
        );
      },
    );
  }
}

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

class Notification {
  final U user;
  final Feed? feed;
  final String? postId;
  final int type;
  final bool read;
  final DateTime createdAt;

  Notification({
    required this.user,
    this.feed,
    this.postId,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> map) {
    return Notification(
      user: U.fromJson(map['user']),
      feed: map['feed'] != null ? Feed.fromJson(map['feed']) : null,
      postId: map['postId'],
      type: map['type'],
      read: map['read'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']['_seconds'] * 1000),
    );
  }
}
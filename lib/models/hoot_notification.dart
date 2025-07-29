import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

class HootNotification {
  final String id;
  final U user;
  final Feed? feed;
  final String? postId;
  final int type;
  final bool read;
  final DateTime createdAt;

  HootNotification({
    required this.id,
    required this.user,
    this.feed,
    this.postId,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory HootNotification.fromJson(Map<String, dynamic> map) {
    return HootNotification(
      id: map['id'],
      user: U.fromJson(map['user']),
      feed: map['feed'] != null ? Feed.fromJson(map['feed']) : null,
      postId: map['postId'],
      type: map['type'],
      read: map['read'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt']['_seconds'] * 1000),
    );
  }
}

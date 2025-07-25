import 'dart:ui';

import 'package:hoot/util/enums/feed_types.dart';
import 'package:hoot/models/post.dart';

class Feed {
  final String id;
  String userId;
  String title;
  String? description;
  String? icon;
  Color? color;
  bool? private;
  bool? nsfw;
  bool? verified;
  FeedType? type;
  final int? subscriberCount;
  final int? requestCount;
  List<Post>? posts;

  Feed({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.icon,
    this.color,
    this.private,
    this.nsfw,
    this.verified,
    this.type,
    this.subscriberCount,
    this.requestCount,
    this.posts
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: Color(int.parse(json['color'])),
      type: json['type'] != null ? FeedType.values.firstWhere((e) => e.toString().split('.').last == json['type']) : null,
      private: json['private'],
      nsfw: json['nsfw'],
      verified: json['verified'],
      subscriberCount: json['subscriberCount'],
      requestCount: json['requestCount'],
      posts: json['posts'] != null ? (json['posts'] as List).map((i) => Post.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'icon': icon,
    'color': color!.hashCode.toString(),
    'type': type.toString().split('.').last,
    'private': private,
    'nsfw': nsfw,
  };

  Map<String, dynamic> toCache() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'icon': icon,
    'color': color!.hashCode.toString(),
    'type': type.toString().split('.').last,
    'private': private,
    'nsfw': nsfw,
    'verified': verified,
    'subscriberCount': subscriberCount,
    'requestCount': requestCount
  };
}
import 'dart:ui';

import 'package:hoot/util/enums/feed_types.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';

class Feed {
  final String id;
  U? user;
  String title;
  String? description;
  String? icon;
  Color? color;
  bool? private;
  bool? nsfw;
  bool? verified;
  FeedType? type;
  final List<String>? subscribers;
  final List<String>? requests;
  List<Post>? posts;

  Feed({
    required this.id,
    this.user,
    required this.title,
    required this.description,
    this.icon,
    this.color,
    this.private,
    this.nsfw,
    this.verified,
    this.type,
    this.subscribers,
    this.requests,
    this.posts
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: Color(int.parse(json['color'])),
      type: json['type'] != null ? FeedType.values.firstWhere((e) => e.toString().split('.').last == json['type']) : null,
      private: json['private'],
      nsfw: json['nsfw'],
      verified: json['verified'],
      subscribers: json['subscribers'] != null ? List<String>.from(json['subscribers']) : null,
      requests: json['requests'] != null ? List<String>.from(json['requests']) : null,
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
    'title': title,
    'description': description,
    'icon': icon,
    'color': color!.hashCode.toString(),
    'type': type.toString().split('.').last,
    'private': private,
    'nsfw': nsfw,
    'verified': verified,
    'subscribers': subscribers,
    'requests': requests
  };
}
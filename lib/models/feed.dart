import 'dart:ui';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';

class Feed {
  final String id;
  final U? user;
  final String title;
  final String? description;
  final String? icon;
  final Color? color;
  final bool? private;
  final bool? nsfw;
  final List<String>? subscribers;
  final List<Post>? posts;

  Feed({
    required this.id,
    this.user,
    required this.title,
    required this.description,
    this.icon,
    this.color,
    this.private,
    this.nsfw,
    this.subscribers,
    this.posts,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      // user: json['user'] != null ? U.fromJson(json['user']) : null,
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: Color(int.parse(json['color'])),
      private: json['private'],
      nsfw: json['nsfw'],
      subscribers: json['subscribers'] != null ? List<String>.from(json['subscribers']) : null,
      posts: json['posts'] != null ? (json['posts'] as List).map((i) => Post.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'icon': icon,
    'color': color!.hashCode.toString(),
    'private': private,
    'nsfw': nsfw,
  };
}
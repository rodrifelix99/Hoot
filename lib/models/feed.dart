import 'dart:ui';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';

class Feed {
  final String id;
  final U? user;
  String title;
  String? description;
  String? icon;
  Color? color;
  bool? private;
  bool? nsfw;
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
      private: json['private'],
      nsfw: json['nsfw'],
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
    'private': private,
    'nsfw': nsfw,
  };
}
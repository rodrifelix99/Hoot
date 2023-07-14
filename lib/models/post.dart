import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

class Post {
  String id;
  String? text;
  List<String>? media;
  U? user;
  String? feedId;
  Feed? feed;
  List<dynamic>? likes;
  List<dynamic>? comments;
  DateTime? createdAt;
  DateTime? updatedAt;

  Post({
    required this.id,
    this.text,
    this.media,
    this.user,
    this.feedId,
    this.feed,
    this.likes,
    this.comments,
    this.createdAt,
    this.updatedAt,
  });

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'],
      media: json['images'] != null ? List<String>.from(json['images']) : null,
      feedId: json['feedId'],
      feed: json['feed'] != null ? Feed.fromJson(json['feed']) : null,
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      likes: json['likes'],
      comments: json['comments'],
      createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']['_seconds'] * 1000) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']['_seconds'] * 1000) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'images': media,
      'feedId': feedId,
    };
  }
}
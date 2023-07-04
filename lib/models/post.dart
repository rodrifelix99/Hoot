import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/user.dart';

class Post {
  String id;
  String? text;
  String? media;
  U? user;
  List<dynamic>? likes;
  List<dynamic>? comments;
  DateTime? createdAt;
  DateTime? updatedAt;

  Post({
    required this.id,
    this.text,
    this.media,
    this.user,
    this.likes,
    this.comments,
    this.createdAt,
    this.updatedAt,
  });

  static Post fromJson(Map<String, dynamic> json) {
    print(json['createdAt']);
    return Post(
      id: json['id'],
      text: json['text'],
      media: json['media'],
      user: U.fromJson(json['user']),
      likes: json['likes'],
      comments: json['comments'],
      // json['createdAt'] = {_seconds: 1688489289, _nanoseconds: 105000000}
      createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']['_seconds'] * 1000) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']['_seconds'] * 1000) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'media': media
    };
  }
}
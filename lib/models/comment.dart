import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/user.dart';

class Comment {
  final String id;
  final String postId;
  String text;
  U? user;
  DateTime? createdAt;
  DateTime? updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.text,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      text: json['text'] ?? '',
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      createdAt: json['createdAt'] != null
          ? json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['createdAt']['_seconds'] * 1000)
          : null,
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['updatedAt']['_seconds'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'postId': postId,
      };

  Map<String, dynamic> toCache() => {
        'id': id,
        'postId': postId,
        'text': text,
        'user': user?.toCache(),
        'createdAt': createdAt?.millisecondsSinceEpoch.toString(),
        'updatedAt': updatedAt?.millisecondsSinceEpoch.toString(),
      };

  factory Comment.fromCache(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      text: json['text'] ?? '',
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(json['createdAt']))
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(json['updatedAt']))
          : null,
    );
  }
}

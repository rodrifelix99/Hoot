import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class FeedJoinRequest {
  final U user;
  final DateTime createdAt;

  FeedJoinRequest({required this.user, required this.createdAt});

  factory FeedJoinRequest.fromJson(Map<String, dynamic> json) {
    return FeedJoinRequest(
      user: U.fromJson(json['user']),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt']['_seconds'] * 1000),
    );
  }
}

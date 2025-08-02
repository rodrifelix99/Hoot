import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/user.dart';

class FeedJoinRequest {
  final String feedId;
  final U user;
  final DateTime createdAt;

  FeedJoinRequest(
      {required this.feedId, required this.user, required this.createdAt});

  factory FeedJoinRequest.fromJson(Map<String, dynamic> json) {
    return FeedJoinRequest(
      feedId: json['feedId'] ?? '',
      user: U.fromJson(json['user']),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(
              json['createdAt']['_seconds'] * 1000),
    );
  }
}

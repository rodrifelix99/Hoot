import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final String id;
  final String message;
  final String? screenshot;
  final String userId;
  final DateTime? createdAt;

  Feedback({
    required this.id,
    required this.message,
    this.screenshot,
    required this.userId,
    required this.createdAt,
  });

  factory Feedback.fromJson(String id, Map<String, dynamic> json) {
    return Feedback(
      id: id,
      message: json['message'] ?? '',
      screenshot: json['screenshot'],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

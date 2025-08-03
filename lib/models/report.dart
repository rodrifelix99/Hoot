import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String type;
  final String targetId;
  final String userId;
  final String reason;
  final DateTime? createdAt;

  Report({
    required this.id,
    required this.type,
    required this.targetId,
    required this.userId,
    required this.reason,
    required this.createdAt,
  });

  factory Report.fromJson(String id, Map<String, dynamic> json) {
    return Report(
      id: id,
      type: json['type'] ?? '',
      targetId: json['targetId'] ?? '',
      userId: json['userId'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

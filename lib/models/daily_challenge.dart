import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallenge {
  final String id;
  final String prompt;
  final String hashtag;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  DailyChallenge({
    required this.id,
    required this.prompt,
    required this.hashtag,
    this.expiresAt,
    this.createdAt,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      prompt: json['prompt'] ?? '',
      hashtag: json['hashtag'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? json['expiresAt'] is Timestamp
              ? (json['expiresAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['expiresAt']['_seconds'] * 1000)
          : null,
      createdAt: json['createdAt'] != null
          ? json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['createdAt']['_seconds'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'hashtag': hashtag,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}

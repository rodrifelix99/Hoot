import 'package:hoot/models/user.dart';

class Notification {
  final U user;
  final int type;
  final DateTime createdAt;

  Notification({
    required this.user,
    required this.type,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> map) {
    return Notification(
      user: U.fromJson(map['user']),
      type: map['type'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']['_seconds'] * 1000),
    );
  }
}
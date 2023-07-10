import 'package:hoot/models/user.dart';

class Notification {
  final U user;
  final int type;
  final bool read;
  final DateTime createdAt;

  Notification({
    required this.user,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> map) {
    return Notification(
      user: U.fromJson(map['user']),
      type: map['type'],
      read: map['read'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']['_seconds'] * 1000),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents aggregated statistics for the application.
class Stats {
  final int totalUsers;
  final int activeUsers;
  final int uninvitedUsers;
  final int reportsCount;

  Stats({
    required this.totalUsers,
    required this.activeUsers,
    required this.uninvitedUsers,
    required this.reportsCount,
  });
}

/// Contract for fetching aggregate statistics.
abstract class BaseStatsService {
  Future<Stats> fetchStats();
}

/// Default implementation that aggregates data from Firestore.
class StatsService implements BaseStatsService {
  final FirebaseFirestore _firestore;

  StatsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Stats> fetchStats() async {
    final results = await Future.wait([
      _firestore.collection('users').get(),
      _firestore
          .collection('users')
          .where('activityScore', isGreaterThan: 0)
          .get(),
      _firestore
          .collection('reports')
          .where('resolved', isEqualTo: false)
          .get(),
    ]);

    final usersSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final uninvitedUsers = usersSnapshot.docs.where((doc) {
      final data = doc.data();
      final code = data['invitationCode'];
      final invitedBy = data['invitedBy'];
      return code == null ||
          (code is String && code.isEmpty) ||
          invitedBy == null ||
          (invitedBy is String && invitedBy.isEmpty);
    }).length;

    return Stats(
      totalUsers: usersSnapshot.size,
      activeUsers: results[1].size,
      reportsCount: results[2].size,
      uninvitedUsers: uninvitedUsers,
    );
  }
}

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
      // Uninvited users: invitationCode is null
      _firestore.collection('users').where('invitationCode', isNull: true).get(),
      // Uninvited users: invitationCode is empty string
      _firestore.collection('users').where('invitationCode', isEqualTo: '').get(),
      // Uninvited users: invitedBy is null
      _firestore.collection('users').where('invitedBy', isNull: true).get(),
      // Uninvited users: invitedBy is empty string
      _firestore.collection('users').where('invitedBy', isEqualTo: '').get(),
    ]);

    final usersSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
    // Uninvited users: combine all matching document IDs to avoid double-counting
    final Set<String> uninvitedUserIds = {};
    for (int i = 3; i <= 6; i++) {
      final QuerySnapshot<Map<String, dynamic>> snap = results[i] as QuerySnapshot<Map<String, dynamic>>;
      for (final doc in snap.docs) {
        uninvitedUserIds.add(doc.id);
      }
    }
    final uninvitedUsers = uninvitedUserIds.length;

    return Stats(
      totalUsers: usersSnapshot.size,
      activeUsers: results[1].size,
      reportsCount: results[2].size,
      uninvitedUsers: uninvitedUsers,
    );
  }
}

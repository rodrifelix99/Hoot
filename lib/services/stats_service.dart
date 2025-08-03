import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents aggregated statistics for the application.
class Stats {
  final int totalUsers;
  final int activeUsers;
  final int reportsCount;

  Stats({
    required this.totalUsers,
    required this.activeUsers,
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

    return Stats(
      totalUsers: results[0].size,
      activeUsers: results[1].size,
      reportsCount: results[2].size,
    );
  }
}

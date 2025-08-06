import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/models/daily_challenge.dart';

/// Abstraction for retrieving daily challenges.
abstract class BaseChallengeService {
  /// Fetches the currently active [DailyChallenge] if any.
  Future<DailyChallenge?> getCurrentChallenge();

  /// Watches the currently active [DailyChallenge] in real-time.
  Stream<DailyChallenge?> watchCurrentChallenge();
}

/// Service communicating with Firestore to retrieve challenges.
class ChallengeService implements BaseChallengeService {
  ChallengeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns the active [DailyChallenge] whose `expiresAt` is in the future.
  @override
  Future<DailyChallenge?> getCurrentChallenge() async {
    final snapshot = await _firestore
        .collection('daily_challenges')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return DailyChallenge.fromJson({'id': doc.id, ...doc.data()});
  }

  /// Streams the active [DailyChallenge] with real-time updates.
  @override
  Stream<DailyChallenge?> watchCurrentChallenge() {
    return _firestore
        .collection('daily_challenges')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return DailyChallenge.fromJson({'id': doc.id, ...doc.data()});
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/models/daily_challenge.dart';
import 'package:hoot/models/post.dart';

/// Abstraction for retrieving daily challenges.
abstract class BaseChallengeService {
  /// Fetches the currently active [DailyChallenge] if any.
  Future<DailyChallenge?> getCurrentChallenge();

  /// Watches the currently active [DailyChallenge] in real-time.
  Stream<DailyChallenge?> watchCurrentChallenge();

  /// Fetches a [DailyChallenge] by its identifier.
  Future<DailyChallenge?> getChallengeById(String id);

  /// Fetches the most recent expired [DailyChallenge] and its top posts
  /// ordered by likes.
  Future<({DailyChallenge challenge, List<Post> posts})?>
      fetchRecentExpiredChallengeTopPosts({int limit = 3});
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

  /// Retrieves a [DailyChallenge] document by [id].
  @override
  Future<DailyChallenge?> getChallengeById(String id) async {
    final doc = await _firestore.collection('daily_challenges').doc(id).get();
    if (!doc.exists) return null;
    return DailyChallenge.fromJson({'id': doc.id, ...doc.data()!});
  }

  /// Retrieves the most recent expired [DailyChallenge] and its top posts
  /// ordered by likes.
  @override
  Future<({DailyChallenge challenge, List<Post> posts})?>
      fetchRecentExpiredChallengeTopPosts({int limit = 3}) async {
    final challengeSnapshot = await _firestore
        .collection('daily_challenges')
        .where('expiresAt', isLessThan: Timestamp.now())
        .orderBy('expiresAt', descending: true)
        .limit(1)
        .get();
    if (challengeSnapshot.docs.isEmpty) return null;
    final challengeDoc = challengeSnapshot.docs.first;
    final challenge = DailyChallenge.fromJson(
        {'id': challengeDoc.id, ...challengeDoc.data()});

    final postsSnapshot = await _firestore
        .collection('posts')
        .where('challengeId', isEqualTo: challenge.id)
        .orderBy('likes', descending: true)
        .limit(limit)
        .get();

    final posts = postsSnapshot.docs
        .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
        .toList();
    return (challenge: challenge, posts: posts);
  }
}

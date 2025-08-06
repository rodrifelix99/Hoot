import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/challenge/challenge_feed_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/constants.dart';
import 'package:hoot/util/enums/feed_types.dart';

void main() {
  group('ChallengeFeedController NSFW filtering', () {
    test('filters adult posts for young accounts', () {
      final auth = AuthService(
          auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());
      final youngDate = DateTime.now().subtract(
        const Duration(days: kAdultContentAccountAgeDays - 1),
      );
      auth.currentUserRx.value = U(uid: 'u1', createdAt: youngDate);
      final controller = ChallengeFeedController(authService: auth);

      final posts = [
        Post(
          id: 'p1',
          feed: Feed(
            id: 'f1',
            userId: 'u1',
            title: 't1',
            description: 'd1',
            nsfw: true,
          ),
        ),
        Post(
          id: 'p2',
          feed: Feed(
            id: 'f2',
            userId: 'u1',
            title: 't2',
            description: 'd2',
            type: FeedType.adultContent,
          ),
        ),
      ];

      final filtered = controller.filterPosts(posts);
      expect(filtered, isEmpty);
    });

    test('keeps posts for old accounts', () {
      final auth = AuthService(
          auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());
      final oldDate = DateTime.now().subtract(
        const Duration(days: kAdultContentAccountAgeDays + 1),
      );
      auth.currentUserRx.value = U(uid: 'u1', createdAt: oldDate);
      final controller = ChallengeFeedController(authService: auth);

      final posts = [
        Post(
          id: 'p1',
          feed: Feed(
            id: 'f1',
            userId: 'u1',
            title: 't1',
            description: 'd1',
            nsfw: true,
          ),
        ),
        Post(
          id: 'p2',
          feed: Feed(
            id: 'f2',
            userId: 'u1',
            title: 't2',
            description: 'd2',
            type: FeedType.adultContent,
          ),
        ),
      ];

      final filtered = controller.filterPosts(posts);
      expect(filtered.length, 2);
    });
  });
}

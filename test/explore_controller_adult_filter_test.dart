import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/explore/controllers/explore_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/constants.dart';
import 'package:hoot/util/enums/feed_types.dart';

void main() {
  group('ExploreController adult content filtering', () {
    test('excludes adult content for young accounts', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({
        'title': 'Adult Feed',
        'titleLowercase': 'adult feed',
        'description': 'desc',
        'color': '0',
        'type': 'adultContent',
        'userId': 'u1',
        'subscriberCount': 1,
        'createdAt': DateTime.now(),
        'nsfw': true,
      });
      await firestore.collection('posts').doc('p1').set({
        'text': 'adult post',
        'likes': 0,
        'createdAt': DateTime.now(),
        'feedId': 'f1',
        'feed': {
          'id': 'f1',
          'title': 'Adult Feed',
          'titleLowercase': 'adult feed',
          'description': 'desc',
          'color': '0',
          'type': 'adultContent',
          'userId': 'u1',
          'subscriberCount': 1,
          'createdAt': DateTime.now(),
          'nsfw': true,
          'private': false,
        },
      });

      final auth = AuthService(auth: MockFirebaseAuth(), firestore: firestore);
      final youngDate = DateTime.now().subtract(
        const Duration(days: kAdultContentAccountAgeDays - 1),
      );
      auth.currentUserRx.value = U(uid: 'u1', createdAt: youngDate);

      final controller = ExploreController(
        firestore: firestore,
        authService: auth,
      );
      await controller.loadTopFeeds();
      await controller.loadTopPosts();
      await controller.loadNewFeeds();
      await controller.loadGenres();

      expect(controller.topFeeds, isEmpty);
      expect(controller.topPosts, isEmpty);
      expect(controller.newFeeds, isEmpty);
      expect(controller.genres, isEmpty);
    });

    test('includes adult content for old accounts', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('feeds').doc('f1').set({
        'title': 'Adult Feed',
        'titleLowercase': 'adult feed',
        'description': 'desc',
        'color': '0',
        'type': 'adultContent',
        'userId': 'u1',
        'subscriberCount': 1,
        'createdAt': DateTime.now(),
        'nsfw': true,
      });
      await firestore.collection('posts').doc('p1').set({
        'text': 'adult post',
        'likes': 0,
        'createdAt': DateTime.now(),
        'feedId': 'f1',
        'feed': {
          'id': 'f1',
          'title': 'Adult Feed',
          'titleLowercase': 'adult feed',
          'description': 'desc',
          'color': '0',
          'type': 'adultContent',
          'userId': 'u1',
          'subscriberCount': 1,
          'createdAt': DateTime.now(),
          'nsfw': true,
          'private': false,
        },
      });

      final auth = AuthService(auth: MockFirebaseAuth(), firestore: firestore);
      final oldDate = DateTime.now().subtract(
        const Duration(days: kAdultContentAccountAgeDays + 1),
      );
      auth.currentUserRx.value = U(uid: 'u1', createdAt: oldDate);

      final controller = ExploreController(
        firestore: firestore,
        authService: auth,
      );
      await controller.loadTopFeeds();
      await controller.loadTopPosts();
      await controller.loadNewFeeds();
      await controller.loadGenres();

      expect(controller.topFeeds.length, 1);
      expect(controller.topFeeds.first.type, FeedType.adultContent);
      expect(controller.topPosts.length, 1);
      expect(controller.topPosts.first.feed?.type, FeedType.adultContent);
      expect(controller.newFeeds.length, 1);
      expect(controller.genres.length, 1);
      expect(controller.genres.first, FeedType.adultContent);
    });
  });
}

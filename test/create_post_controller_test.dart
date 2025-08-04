import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';

import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:get/get.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/storage_service.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/services/news_service.dart';
import 'package:hoot/util/enums/feed_types.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U _user;

  FakeAuthService(this._user);

  @override
  U? get currentUser => _user;

  @override
  Stream<U?> get currentUserStream => Stream.value(_user);

  @override
  Rxn<U> get currentUserRx => Rxn<U>()..value = _user;

  @override
  Future<U?> fetchUser() async => _user;

  @override
  Future<U?> fetchUserById(String uid) async => _user;

  @override
  Future<U?> fetchUserByUsername(String username) async => _user;

  @override
  Future<List<U>> searchUsers(String query, {int limit = 5}) async => [];

  @override
  Future<void> signOut() async {}

  @override
  Future<UserCredential> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserCredential> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<U?> refreshUser() async => _user;

  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}

  @override
  String? displayName;

  @override
  // TODO: implement isStaff
  bool get isStaff => throw UnimplementedError();
}

class FakeStorageService extends GetxService implements BaseStorageService {
  List<List<File>> calls = [];

  @override
  Future<List<UploadedPostImage>> uploadPostImages(
      String postId, List<File> files) async {
    calls.add(files);
    return files
        .map((f) => UploadedPostImage(
            url: 'https://example.com/${f.path.split('/').last}',
            blurHash: 'hash'))
        .toList();
  }
}

class FakeNewsService implements BaseNewsService {
  final Map<String?, List<NewsItem>> topicItems;
  final List<String?> calls = [];
  FakeNewsService({List<NewsItem> items = const [], Map<String?, List<NewsItem>>? topicItems})
      : topicItems = topicItems ?? {null: items};

  @override
  Future<List<NewsItem>> fetchTrendingNews({String? topic}) async {
    calls.add(topic);
    return topicItems[topic] ?? [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreatePostController', () {
    testWidgets('publish fails when no feed is selected', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue,
                order: 0)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: FakeNewsService());
      controller.textController.text = 'Hello';
      expect(await controller.publish(), isNull);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('publish fails when text exceeds 280 chars', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue,
                order: 0)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: FakeNewsService());
      controller.textController.text = 'a' * 281;
      controller.selectedFeeds.add(
        Feed(
          id: 'f1',
          userId: 't',
          title: 't',
          description: 'd',
          color: Colors.blue,
          order: 0,
        ),
      );
      expect(await controller.publish(), isNull);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('successful publish writes document', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue,
                order: 0)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: FakeNewsService());
      controller.selectedFeeds.add(Feed(
        id: 'f1',
        userId: 't',
        title: 't',
        description: 'd',
        color: Colors.blue,
        order: 0,
      ));
      controller.textController.text = 'Hi';
      final result = await controller.publish();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(result, isA<Post>());
      final posts = await firestore.collection('posts').get();
      expect(posts.docs.length, 1);
      final data = posts.docs.first.data();
      expect(data['text'], 'Hi');
      expect(data['user']['displayName'], 'Tester');
      expect(data['user']['username'], 'tester');
      expect(data['user']['smallAvatar'], 'a.png');
      expect(data['feed']['title'], 't');
    });

    testWidgets('publish creates a post for each selected feed',
        (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final feeds = [
        Feed(
            id: 'f1',
            userId: 'u1',
            title: 't1',
            description: 'd1',
            color: Colors.blue),
        Feed(
            id: 'f2',
            userId: 'u1',
            title: 't2',
            description: 'd2',
            color: Colors.red),
      ];
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: feeds));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: FakeNewsService());
      controller.selectedFeeds.assignAll(feeds);
      controller.textController.text = 'Hi';
      await controller.publish();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final posts = await firestore.collection('posts').get();
      expect(posts.docs.length, 2);
      final feedIds = posts.docs.map((e) => e.data()['feedId']).toSet();
      expect(feedIds, {'f1', 'f2'});
    });

    testWidgets('images are uploaded and urls stored', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue,
                order: 0)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: FakeNewsService());

      controller.selectedFeeds.add(Feed(
        id: 'f1',
        userId: 't',
        title: 't',
        description: 'd',
        color: Colors.blue,
        order: 0,
      ));
      final file = File('${Directory.systemTemp.path}/img.jpg')
        ..writeAsBytesSync([0]);
      addTearDown(() => file.deleteSync());
      controller.imageFiles.add(file);
      controller.textController.text = 'Hi';
      final result = await controller.publish();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(result, isA<Post>());
      expect(storage.calls.length, 1);
      final posts = await firestore.collection('posts').get();
      expect(
          posts.docs.first.data()['images'][0], 'https://example.com/img.jpg');
      expect(posts.docs.first.data()['hashes'][0], 'hash');
    });

    testWidgets('available feeds loaded on init', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final feed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 't',
          description: 'd',
          color: Colors.blue,
          order: 0);
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [feed]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: FakeNewsService());
      Get.put(controller);
      await tester.pump();
      expect(controller.availableFeeds.length, 1);
      expect(controller.availableFeeds.first.id, 'f1');
      Get.reset();
    });

    testWidgets('trending news loaded on init', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final feed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 't',
          description: 'd',
          color: Colors.blue,
          order: 0);
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [feed]));
      final storage = FakeStorageService();
      final news = FakeNewsService(
          items: [NewsItem(title: 'News 1', link: 'https://example.com')]);
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: news);
      controller.onInit();
      await tester.pump();
      expect(controller.trendingNews.length, 1);
      expect(controller.trendingNews.first.title, 'News 1');
    });

    testWidgets('selecting feed loads topic news and resets on deselect',
        (tester) async {
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final feed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 't',
          description: 'd',
          color: Colors.blue,
          order: 0,
          type: FeedType.technology);
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [feed]));
      final storage = FakeStorageService();
      final generalNews =
          [NewsItem(title: 'General', link: 'https://example.com')];
      final techNews = [NewsItem(title: 'Tech', link: 'https://tech.com')];
      final news = FakeNewsService(topicItems: {
        null: generalNews,
        'TECHNOLOGY': techNews,
      });
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: news);
      controller.onInit();
      await tester.pump();
      expect(news.calls, [null]);
      expect(controller.trendingNews.first.title, 'General');

      controller.selectedFeeds.add(feed);
      await tester.pump();
      expect(news.calls, [null, 'TECHNOLOGY']);
      expect(controller.trendingNews.first.title, 'Tech');

      controller.selectedFeeds.clear();
      await tester.pump();
      expect(news.calls, [null, 'TECHNOLOGY', null]);
      expect(controller.trendingNews.first.title, 'General');
    });

    testWidgets('switching selected feed refreshes headlines', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final techFeed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 'tech',
          description: 'd',
          color: Colors.blue,
          order: 0,
          type: FeedType.technology);
      final scienceFeed = Feed(
          id: 'f2',
          userId: 'u1',
          title: 'science',
          description: 'd',
          color: Colors.red,
          order: 0,
          type: FeedType.science);
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [techFeed, scienceFeed]));
      final storage = FakeStorageService();
      final generalNews =
          [NewsItem(title: 'General', link: 'https://example.com')];
      final techNews = [NewsItem(title: 'Tech', link: 'https://tech.com')];
      final scienceNews =
          [NewsItem(title: 'Science', link: 'https://science.com')];
      final news = FakeNewsService(topicItems: {
        null: generalNews,
        'TECHNOLOGY': techNews,
        'SCIENCE': scienceNews,
      });
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: news);
      controller.onInit();
      await tester.pump();
      expect(news.calls, [null]);
      expect(controller.trendingNews.first.title, 'General');

      controller.selectedFeeds.add(techFeed);
      await tester.pump();
      expect(news.calls, [null, 'TECHNOLOGY']);
      expect(controller.trendingNews.first.title, 'Tech');

      controller.selectedFeeds[0] = scienceFeed;
      controller.selectedFeeds.refresh();
      await tester.pump();
      expect(news.calls.last, 'SCIENCE');
      expect(controller.trendingNews.first.title, 'Science');
    });

    testWidgets('falls back to general news when topic returns empty',
        (tester) async {
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final feed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 't',
          description: 'd',
          color: Colors.blue,
          order: 0,
          type: FeedType.science);
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [feed]));
      final storage = FakeStorageService();
      final generalNews =
          [NewsItem(title: 'General', link: 'https://example.com')];
      final news = FakeNewsService(topicItems: {
        null: generalNews,
        'SCIENCE': [],
      });
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage,
          newsService: news);
      controller.onInit();
      await tester.pump();
      controller.selectedFeeds.add(feed);
      await tester.pump();
      expect(news.calls, [null, 'SCIENCE', null]);
      expect(controller.trendingNews.first.title, 'General');
    });
  });
}

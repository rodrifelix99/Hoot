import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/feed_editor/controllers/feed_editor_controller.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_manager.dart';
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

class FakeFirebaseStorage extends Fake implements FirebaseStorage {}

class FakeFeedService implements BaseFeedService {
  @override
  Future<PostPage> fetchSubscribedPosts({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    return PostPage(posts: []);
  }

  @override
  Future<PostPage> fetchFeedPosts(String feedId,
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    return PostPage(posts: []);
  }

  @override
  Future<void> updateFeedOrder(List<Feed> feeds) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('successful create writes document', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final auth = FakeAuthService(U(uid: 'u1'));
    final controller = FeedEditorController(
        firestore: firestore,
        userId: 'u1',
        authService: auth,
        storage: FakeFirebaseStorage());
    controller.titleController.text = 'My Feed';
    controller.descriptionController.text = 'Desc';
    controller.selectedType.value = FeedType.music;

    final result = await controller.submit();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    final feeds = await firestore.collection('feeds').get();
    expect(feeds.docs.length, 1);
    expect(feeds.docs.first.get('title'), 'My Feed');
    expect(feeds.docs.first.get('type'), 'music');
  });

  testWidgets('create fails without title', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final auth = FakeAuthService(U(uid: 'u1'));
    final controller = FeedEditorController(
        firestore: firestore,
        userId: 'u1',
        authService: auth,
        storage: FakeFirebaseStorage());
    controller.selectedType.value = FeedType.music;

    final result = await controller.submit();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    final feeds = await firestore.collection('feeds').get();
    expect(feeds.docs.length, 0);
  });

  testWidgets('create fails without genre', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final auth = FakeAuthService(U(uid: 'u1'));
    final controller = FeedEditorController(
        firestore: firestore,
        userId: 'u1',
        authService: auth,
        storage: FakeFirebaseStorage());
    controller.titleController.text = 'Feed';

    final result = await controller.submit();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    final feeds = await firestore.collection('feeds').get();
    expect(feeds.docs.length, 0);
  });

  testWidgets('profile controller is updated on success', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final user = U(uid: 'u1', feeds: []);
    final auth = FakeAuthService(user);
    final subService = SubscriptionService(
      firestore: firestore,
    );
    final feedRequestService = FeedRequestService(
      firestore: firestore,
      subscriptionService: subService,
      authService: auth,
    );
    final subManager = SubscriptionManager(
      firestore: firestore,
      subscriptionService: subService,
      feedRequestService: feedRequestService,
    );
    final profile = ProfileController(
      authService: auth,
      feedService: FakeFeedService(),
      subscriptionService: subService,
      feedRequestService: feedRequestService,
      subscriptionManager: subManager,
    );
    Get.put<AuthService>(auth);
    Get.put<SubscriptionService>(subService);
    Get.put<FeedRequestService>(feedRequestService);
    Get.put<SubscriptionManager>(subManager);
    Get.put<ProfileController>(profile);

    final controller = FeedEditorController(
        firestore: firestore,
        userId: 'u1',
        authService: auth,
        profileController: profile,
        storage: FakeFirebaseStorage());
    controller.titleController.text = 'My Feed';
    controller.selectedType.value = FeedType.music;

    final result = await controller.submit();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(profile.feeds.length, 1);
    expect(profile.feeds.first.title, 'My Feed');

    Get.reset();
  });

  testWidgets('creator is subscribed to new feed', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final auth = FakeAuthService(U(uid: 'u1'));
    final controller = FeedEditorController(
        firestore: firestore,
        userId: 'u1',
        authService: auth,
        storage: FakeFirebaseStorage());
    controller.titleController.text = 'My Feed';
    controller.selectedType.value = FeedType.music;

    final result = await controller.submit();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    final feeds = await firestore.collection('feeds').get();
    final feedId = feeds.docs.first.id;
    final subs = await firestore
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .get();
    expect(subs.docs.length, 1);
    expect(subs.docs.first.id, feedId);
  });

  testWidgets('submit updates existing feed', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    await firestore.collection('feeds').doc('f1').set({
      'title': 'Old',
      'description': 'Old desc',
      'color': Colors.blue.value.toString(),
      'type': 'music',
      'private': false,
      'nsfw': false,
      'userId': 'u1',
    });
    final feed = Feed(
      id: 'f1',
      userId: 'u1',
      title: 'Old',
      description: 'Old desc',
      color: Colors.blue,
      type: FeedType.music,
      private: false,
      nsfw: false,
      subscriberCount: 0,
      order: 0,
    );
    final user = U(uid: 'u1', feeds: [feed]);
    final auth = FakeAuthService(user);

    final controller = FeedEditorController(
        firestore: firestore,
        authService: auth,
        feed: feed,
        userId: 'u1',
        storage: FakeFirebaseStorage());
    controller.onInit();
    controller.titleController.text = 'New';

    final result = await controller.submit();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    final doc = await firestore.collection('feeds').doc('f1').get();
    expect(doc.get('title'), 'New');
  });
}

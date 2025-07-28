import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/pages/create_feed/controllers/create_feed_controller.dart';
import 'package:hoot/util/enums/feed_types.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U _user;
  FakeAuthService(this._user);

  @override
  U? get currentUser => _user;

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
}

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('successful create writes document', (tester) async {
    await tester.pumpWidget(const ToastificationWrapper(
      child: MaterialApp(home: Scaffold(body: SizedBox())),
    ));

    final firestore = FakeFirebaseFirestore();
    final auth = FakeAuthService(U(uid: 'u1'));
    final controller = CreateFeedController(
        firestore: firestore, userId: 'u1', authService: auth);
    controller.titleController.text = 'My Feed';
    controller.descriptionController.text = 'Desc';
    controller.selectedType.value = FeedType.music;

    final result = await controller.createFeed();
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
    final controller = CreateFeedController(
        firestore: firestore, userId: 'u1', authService: auth);
    controller.selectedType.value = FeedType.music;

    final result = await controller.createFeed();
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
    final controller = CreateFeedController(
        firestore: firestore, userId: 'u1', authService: auth);
    controller.titleController.text = 'Feed';

    final result = await controller.createFeed();
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
    final profile = ProfileController(
      authService: auth,
      feedService: FakeFeedService(),
      subscriptionService: subService,
    );
    Get.put<AuthService>(auth);
    Get.put<SubscriptionService>(subService);
    Get.put<ProfileController>(profile);

    final controller = CreateFeedController(
        firestore: firestore,
        userId: 'u1',
        authService: auth,
        profileController: profile);
    controller.titleController.text = 'My Feed';
    controller.selectedType.value = FeedType.music;

    final result = await controller.createFeed();
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
    final controller = CreateFeedController(
        firestore: firestore, userId: 'u1', authService: auth);
    controller.titleController.text = 'My Feed';
    controller.selectedType.value = FeedType.music;

    final result = await controller.createFeed();
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
}

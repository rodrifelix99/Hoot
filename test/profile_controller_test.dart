import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/feed_service.dart';
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

class FakeSubscriptionService extends SubscriptionService {
  final List<List<String>> subscribeCalls = [];
  FakeSubscriptionService() : super(firestore: FakeFirebaseFirestore());

  @override
  Future<void> subscribe(String userId, String feedId) async {
    subscribeCalls.add([userId, feedId]);
  }
}

class FakeFeedRequestService extends FeedRequestService {
  final List<List<String>> submitCalls = [];
  FakeFeedRequestService()
      : super(
          firestore: FakeFirebaseFirestore(),
          subscriptionService: SubscriptionService(
            firestore: FakeFirebaseFirestore(),
          ),
          authService: FakeAuthService(U(uid: 'owner')),
        );

  @override
  Future<void> submit(String feedId, String userId) async {
    submitCalls.add([feedId, userId]);
  }
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

  group('ProfileController.toggleSubscription', () {
    testWidgets('public feed subscribes', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final user = U(uid: 'u1', feeds: [
        Feed(
            id: 'f1',
            userId: 'u2',
            title: 'f',
            description: 'd',
            private: false)
      ]);
      final auth = FakeAuthService(user);
      final subService = FakeSubscriptionService();
      final requestService = FakeFeedRequestService();
      final controller = ProfileController(
        authService: auth,
        feedService: FakeFeedService(),
        subscriptionService: subService,
        feedRequestService: requestService,
      );
      controller.feeds.assignAll(user.feeds ?? []);
      Get.put<AuthService>(auth);
      Get.put<SubscriptionService>(subService);
      Get.put<FeedRequestService>(requestService);
      Get.put<ProfileController>(controller);

      await controller.toggleSubscription('f1');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(subService.subscribeCalls.length, 1);
      expect(requestService.submitCalls, isEmpty);
      Get.reset();
    });

    testWidgets('private feed submits request', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final user = U(uid: 'u1', feeds: [
        Feed(
            id: 'f1', userId: 'u2', title: 'f', description: 'd', private: true)
      ]);
      final auth = FakeAuthService(user);
      final subService = FakeSubscriptionService();
      final requestService = FakeFeedRequestService();
      final controller = ProfileController(
        authService: auth,
        feedService: FakeFeedService(),
        subscriptionService: subService,
        feedRequestService: requestService,
      );
      controller.feeds.assignAll(user.feeds ?? []);
      Get.put<AuthService>(auth);
      Get.put<SubscriptionService>(subService);
      Get.put<FeedRequestService>(requestService);
      Get.put<ProfileController>(controller);

      await controller.toggleSubscription('f1');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(subService.subscribeCalls, isEmpty);
      expect(requestService.submitCalls.length, 1);
      Get.reset();
    });
  });
}

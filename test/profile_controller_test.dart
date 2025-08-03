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
import 'package:hoot/services/subscription_manager.dart';
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
}

class DummySubscriptionService extends SubscriptionService {
  DummySubscriptionService() : super(firestore: FakeFirebaseFirestore());

  @override
  Future<Set<String>> fetchSubscriptions(String userId) async => {};

  @override
  Future<List<Feed>> fetchSubscribedFeeds(String userId) async => [];

  @override
  Future<void> subscribe(String userId, String feedId) async {}

  @override
  Future<void> unsubscribe(String userId, String feedId) async {}
}

class DummyFeedRequestService extends FeedRequestService {
  DummyFeedRequestService()
      : super(
          firestore: FakeFirebaseFirestore(),
          subscriptionService: SubscriptionService(
            firestore: FakeFirebaseFirestore(),
          ),
          authService: FakeAuthService(U(uid: 'owner')),
        );

  @override
  Future<void> submit(String feedId, String userId) async {}

  @override
  Future<bool> exists(String feedId, String userId) async => false;
}

class FakeSubscriptionManager extends SubscriptionManager {
  final SubscriptionResult result;
  final List<List<String>> calls = [];
  FakeSubscriptionManager(this.result)
      : super(
          firestore: FakeFirebaseFirestore(),
          subscriptionService: SubscriptionService(
            firestore: FakeFirebaseFirestore(),
          ),
          feedRequestService: FeedRequestService(
            firestore: FakeFirebaseFirestore(),
            subscriptionService: SubscriptionService(
              firestore: FakeFirebaseFirestore(),
            ),
            authService: FakeAuthService(U(uid: 'owner')),
          ),
        );

  @override
  Future<SubscriptionResult> toggle(String feedId, U user) async {
    calls.add([feedId, user.uid]);
    return result;
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

  @override
  Future<void> updateFeedOrder(List<Feed> feeds) async {}
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
            private: false,
            order: 0)
      ]);
      final auth = FakeAuthService(user);
      final manager = FakeSubscriptionManager(SubscriptionResult.subscribed);
      final subService = DummySubscriptionService();
      final requestService = DummyFeedRequestService();
      Get.put<AuthService>(auth);
      Get.put<SubscriptionService>(subService);
      Get.put<FeedRequestService>(requestService);
      Get.put<SubscriptionManager>(manager);
      final controller = ProfileController(
        authService: auth,
        feedService: FakeFeedService(),
        subscriptionManager: manager,
      );
      controller.feeds.assignAll(user.feeds ?? []);
      Get.put<ProfileController>(controller);

      await controller.toggleSubscription('f1');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(manager.calls.length, 1);
      expect(controller.requestedFeedIds.contains('f1'), isFalse);
      Get.reset();
    });

    testWidgets('private feed submits request', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final user = U(uid: 'u1', feeds: [
        Feed(
            id: 'f1',
            userId: 'u2',
            title: 'f',
            description: 'd',
            private: true,
            order: 0)
      ]);
      final auth = FakeAuthService(user);
      final manager = FakeSubscriptionManager(SubscriptionResult.requested);
      final subService = DummySubscriptionService();
      final requestService = DummyFeedRequestService();
      Get.put<AuthService>(auth);
      Get.put<SubscriptionService>(subService);
      Get.put<FeedRequestService>(requestService);
      Get.put<SubscriptionManager>(manager);
      final controller = ProfileController(
        authService: auth,
        feedService: FakeFeedService(),
        subscriptionManager: manager,
      );
      controller.feeds.assignAll(user.feeds ?? []);
      Get.put<ProfileController>(controller);

      await controller.toggleSubscription('f1');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(manager.calls.length, 1);
      expect(controller.requestedFeedIds.contains('f1'), isTrue);
      Get.reset();
    });
  });
}

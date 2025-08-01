import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/pages/notifications/views/notifications_view.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/hoot_notification.dart';
import 'package:hoot/models/feed_join_request.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}

class FakeFeedRequestService extends FeedRequestService {
  final int count;
  final List<FeedJoinRequest> preview;
  FakeFeedRequestService(this.count, [this.preview = const []])
      : super(
            firestore: FakeFirebaseFirestore(),
            subscriptionService: SubscriptionService(
              firestore: FakeFirebaseFirestore(),
            ),
            authService: FakeAuthService(U(uid: 'owner')));

  @override
  Future<int> pendingRequestCount() async => count;

  @override
  Future<List<FeedJoinRequest>> fetchRequestsForMyFeeds() async => preview;
}

class TestNotificationsController extends NotificationsController {
  TestNotificationsController({
    required AuthService authService,
    required BaseNotificationService notificationService,
    required FeedRequestService feedRequestService,
  }) : super(
            authService: authService,
            notificationService: notificationService,
            feedRequestService: feedRequestService);

  @override
  void onInit() {
    // Override to avoid fetching data from services during tests.
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NotificationsView lists notifications', (tester) async {
    final controller = TestNotificationsController(
      authService: FakeAuthService(U(uid: 'u1')),
      notificationService:
          NotificationService(firestore: FakeFirebaseFirestore()),
      feedRequestService: FakeFeedRequestService(0),
    );
    controller.loading.value = false;
    controller.notifications.assignAll([
      HootNotification(
        id: 'n1',
        user: U(uid: 'u2', username: 'Tester'),
        type: 0,
        read: false,
        createdAt: DateTime.now(),
      ),
    ]);
    Get.put<NotificationsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const NotificationsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tester liked your hoot'), findsOneWidget);
    Get.reset();
  });

  testWidgets('NotificationsView shows reFeed notification', (tester) async {
    final controller = TestNotificationsController(
      authService: FakeAuthService(U(uid: 'u1')),
      notificationService:
          NotificationService(firestore: FakeFirebaseFirestore()),
      feedRequestService: FakeFeedRequestService(0),
    );
    controller.loading.value = false;
    controller.notifications.assignAll([
      HootNotification(
        id: 'n2',
        user: U(uid: 'u2', username: 'Tester'),
        type: 4,
        postId: 'p1',
        read: false,
        createdAt: DateTime.now(),
      ),
    ]);
    Get.put<NotificationsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const NotificationsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tester reFeeded your hoot'), findsOneWidget);
    Get.reset();
  });

  testWidgets('NotificationsView shows friend joined notification',
      (tester) async {
    final controller = TestNotificationsController(
      authService: FakeAuthService(U(uid: 'u1')),
      notificationService:
          NotificationService(firestore: FakeFirebaseFirestore()),
      feedRequestService: FakeFeedRequestService(0),
    );
    controller.loading.value = false;
    controller.notifications.assignAll([
      HootNotification(
        id: 'n3',
        user: U(uid: 'u2', username: 'Tester'),
        type: 5,
        read: false,
        createdAt: DateTime.now(),
      ),
    ]);
    Get.put<NotificationsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const NotificationsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tester joined Hoot using your invite code'), findsOneWidget);
    Get.reset();
  });

  testWidgets('Shows Subscriber Requests button when there are requests',
      (tester) async {
    final controller = TestNotificationsController(
      authService: FakeAuthService(U(uid: 'u1')),
      notificationService:
          NotificationService(firestore: FakeFirebaseFirestore()),
      feedRequestService: FakeFeedRequestService(2),
    );
    controller.loading.value = false;
    controller.requestCount.value = 2;
    Get.put<NotificationsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const NotificationsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Subscriber Requests (2)'), findsOneWidget);
    Get.reset();
  });

  testWidgets('Displays requester avatars in feed requests button',
      (tester) async {
    final requests = [
      FeedJoinRequest(
          feedId: 'f1', user: U(uid: 'u2'), createdAt: DateTime.now()),
      FeedJoinRequest(
          feedId: 'f2', user: U(uid: 'u3'), createdAt: DateTime.now()),
    ];
    final controller = TestNotificationsController(
      authService: FakeAuthService(U(uid: 'u1')),
      notificationService:
          NotificationService(firestore: FakeFirebaseFirestore()),
      feedRequestService: FakeFeedRequestService(2, requests),
    );
    controller.loading.value = false;
    controller.requestCount.value = 2;
    controller.requestUsers.assignAll(requests.map((r) => r.user));
    Get.put<NotificationsController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const NotificationsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileAvatarComponent), findsNWidgets(2));
    Get.reset();
  });
}

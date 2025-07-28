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
import 'package:firebase_auth/firebase_auth.dart';

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

class FakeFeedRequestService extends FeedRequestService {
  final int count;
  FakeFeedRequestService(this.count)
      : super(
            firestore: FakeFirebaseFirestore(),
            subscriptionService: SubscriptionService(
              firestore: FakeFirebaseFirestore(),
            ),
            authService: FakeAuthService(U(uid: 'owner')));

  @override
  Future<int> pendingRequestCount() async => count;
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

    expect(find.text('Subscriber Requests'), findsOneWidget);
    Get.reset();
  });
}

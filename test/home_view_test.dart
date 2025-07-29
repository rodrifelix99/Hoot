import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/pages/home/views/home_view.dart';
import 'package:hoot/pages/home/controllers/home_controller.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/models/user.dart';

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
  FakeFeedRequestService()
      : super(
            firestore: FakeFirebaseFirestore(),
            subscriptionService:
                SubscriptionService(firestore: FakeFirebaseFirestore()),
            authService: FakeAuthService(U(uid: 'owner')));

  @override
  Future<int> pendingRequestCount() async => 0;
}

class TestNotificationsController extends NotificationsController {
  TestNotificationsController()
      : super(
            authService: FakeAuthService(U(uid: 'u1')),
            notificationService:
                NotificationService(firestore: FakeFirebaseFirestore()),
            feedRequestService: FakeFeedRequestService());
}

void main() {
  testWidgets('HomeView displays unread count badge', (tester) async {
    Get.put<AuthService>(FakeAuthService(U(uid: 'u1', username: 't')));
    Get.put(HomeController());
    final n = TestNotificationsController();
    n.unreadCount.value = 2;
    Get.put<NotificationsController>(n);

    await tester.pumpWidget(const GetCupertinoApp(home: HomeView()));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    Get.reset();
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hoot/models/hoot_notification.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/models/feed_join_request.dart';

class FakeStreamSubscription<T> implements StreamSubscription<T> {
  bool canceled = false;
  @override
  Future<void> cancel() async {
    canceled = true;
  }

  @override
  void onData(void Function(T data)? handleData) {}
  @override
  void onError(Function? handleError) {}
  @override
  void onDone(void Function()? handleDone) {}
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  bool get isPaused => false;
  @override
  Future<E> asFuture<E>([E? futureValue]) => Future.value(futureValue);
}

class FakeUnreadStream extends Stream<int> {
  final FakeStreamSubscription<int> sub;
  FakeUnreadStream(this.sub);
  @override
  StreamSubscription<int> listen(void Function(int)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return sub;
  }
}

class FakeNotificationService extends GetxService
    implements BaseNotificationService {
  final FakeStreamSubscription<int> fakeSub;
  FakeNotificationService(this.fakeSub);
  @override
  Stream<int> unreadCountStream(String userId) => FakeUnreadStream(fakeSub);
  @override
  Future<List<HootNotification>> fetchNotifications(String userId) async => [];
  @override
  Future<void> createNotification(
      String userId, Map<String, dynamic> data) async {}
  @override
  Future<void> markAsRead(String userId, String notificationId) async {}
  @override
  Future<void> markAllAsRead(String userId) async {}
}

class FakeFeedRequestService extends FeedRequestService {
  FakeFeedRequestService()
      : super(
            firestore: FakeFirebaseFirestore(),
            subscriptionService:
                SubscriptionService(firestore: FakeFirebaseFirestore()),
            authService: FakeAuthService(U(uid: 'u1')));
  @override
  Future<int> pendingRequestCount() async => 0;
  @override
  Future<List<FeedJoinRequest>> fetchRequests(String feedId) async => [];
  @override
  Future<List<FeedJoinRequest>> fetchRequestsForMyFeeds() async => [];
  @override
  Future<void> submit(String feedId, String userId) async {}
  @override
  Future<void> accept(String feedId, String userId) async {}
  @override
  Future<void> reject(String feedId, String userId) async {}
  @override
  Future<bool> exists(String feedId, String userId) async => false;
}

class FakeAuthService extends GetxService implements AuthService {
  final U user;
  FakeAuthService(this.user);
  @override
  U? get currentUser => user;
  @override
  Stream<U?> get currentUserStream => Stream.value(user);
  @override
  Rxn<U> get currentUserRx => Rxn<U>()..value = user;
  @override
  Future<U?> fetchUser() async => user;
  @override
  Future<U?> fetchUserById(String uid) async => user;
  @override
  Future<U?> fetchUserByUsername(String username) async => user;
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
  Future<U?> refreshUser() async => user;
  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onClose cancels unread subscription', () {
    final fakeSub = FakeStreamSubscription<int>();
    final controller = NotificationsController(
      authService: FakeAuthService(U(uid: 'u1')),
      notificationService: FakeNotificationService(fakeSub),
      feedRequestService: FakeFeedRequestService(),
    );
    controller.onInit();
    controller.onClose();
    expect(fakeSub.canceled, isTrue);
  });
}

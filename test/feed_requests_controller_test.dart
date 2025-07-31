import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/feed_join_request.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/feed_requests/controllers/feed_requests_controller.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/auth_service.dart';

class FakeAuthService extends GetxService implements AuthService {
  @override
  U? get currentUser => null;
  @override
  Stream<U?> get currentUserStream => const Stream.empty();
  @override
  Rxn<U> get currentUserRx => Rxn<U>();
  @override
  Future<U?> fetchUser() async => null;
  @override
  Future<U?> fetchUserById(String uid) async => null;
  @override
  Future<U?> fetchUserByUsername(String username) async => null;
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
  Future<U?> refreshUser() async => null;
  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}
}

class FakeFeedRequestService extends FeedRequestService {
  List<String> acceptCalls = [];
  List<String> rejectCalls = [];
  List<String> fetchCalls = [];
  List<FeedJoinRequest> requests = [];
  FakeFeedRequestService()
      : super(
          firestore: FakeFirebaseFirestore(),
          subscriptionService: SubscriptionService(firestore: FakeFirebaseFirestore()),
          authService: FakeAuthService());
  @override
  Future<void> accept(String feedId, String userId) async {
    acceptCalls.add(userId);
  }
  @override
  Future<void> reject(String feedId, String userId) async {
    rejectCalls.add(userId);
  }
  @override
  Future<List<FeedJoinRequest>> fetchRequests(String feedId) async {
    fetchCalls.add(feedId);
    return requests;
  }
  @override
  Future<void> submit(String feedId, String userId) async {}
  @override
  Future<bool> exists(String feedId, String userId) async => false;
  @override
  Future<int> pendingRequestCount() async => 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadRequests populates list', () async {
    final service = FakeFeedRequestService();
    service.requests = [FeedJoinRequest(user: U(uid: 'u1'), createdAt: DateTime.now())];
    final controller = FeedRequestsController(service: service);
    controller.feedId = "f1";
    await controller.loadRequests();
    expect(service.fetchCalls, contains("f1"));
    expect(controller.requests.length, 1);
  });
  test('accept removes request', () async {
    final service = FakeFeedRequestService();
    service.requests = [FeedJoinRequest(user: U(uid: 'u1'), createdAt: DateTime.now())];
    final controller = FeedRequestsController(service: service);
    controller.feedId = 'f1';
    controller.requests.assignAll(service.requests);
    await controller.accept('u1');
    expect(service.acceptCalls, ['u1']);
    expect(controller.requests.isEmpty, isTrue);
  });

  test('reject removes request', () async {
    final service = FakeFeedRequestService();
    service.requests = [FeedJoinRequest(user: U(uid: 'u1'), createdAt: DateTime.now())];
    final controller = FeedRequestsController(service: service);
    controller.feedId = 'f1';
    controller.requests.assignAll(service.requests);
    await controller.reject('u1');
    expect(service.rejectCalls, ['u1']);
    expect(controller.requests.isEmpty, isTrue);
  });
}


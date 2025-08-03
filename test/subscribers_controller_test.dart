import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/subscribers/controllers/subscribers_controller.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/auth_service.dart';

class FakeSubscriptionService extends SubscriptionService {
  List<String> removeCalls = [];
  List<String> banCalls = [];
  List<String> fetchCalls = [];
  List<U> subs = [];
  FakeSubscriptionService() : super(firestore: FakeFirebaseFirestore());
  @override
  Future<List<U>> fetchSubscribers(String feedId) async {
    fetchCalls.add(feedId);
    return subs;
  }
  @override
  Future<void> removeSubscriber(String feedId, String userId) async {
    removeCalls.add(userId);
  }
  @override
  Future<void> banSubscriber(String feedId, String userId) async {
    banCalls.add(userId);
  }
  @override
  Future<void> subscribe(String userId, String feedId) async {}
  @override
  Future<void> unsubscribe(String userId, String feedId) async {}
  @override
  Future<Set<String>> fetchSubscriptions(String userId) async => {};
  @override
  Future<List<Feed>> fetchSubscribedFeeds(String userId) async => [];
}

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

  @override
  String? displayName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadSubscribers populates list', () async {
    final service = FakeSubscriptionService();
    service.subs = [U(uid: 'u1')];
    final controller = SubscribersController(subscriptionService: service);
    controller.feedId = "f1";
    await controller.loadSubscribers();
    expect(service.fetchCalls, contains("f1"));
  });

  test('removeSubscriber updates list', () async {
    final service = FakeSubscriptionService();
    service.subs = [U(uid: 'u1')];
    final controller = SubscribersController(subscriptionService: service);
    controller.feedId = 'f1';
    controller.subscribers.assignAll(service.subs);
    await controller.removeSubscriber('u1');
    expect(service.removeCalls, ['u1']);
    expect(controller.subscribers.isEmpty, isTrue);
  });

  test('banSubscriber updates list', () async {
    final service = FakeSubscriptionService();
    service.subs = [U(uid: 'u1')];
    final controller = SubscribersController(subscriptionService: service);
    controller.feedId = 'f1';
    controller.subscribers.assignAll(service.subs);
    await controller.banSubscriber('u1');
    expect(service.banCalls, ['u1']);
    expect(controller.subscribers.isEmpty, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/feed_page/controllers/feed_page_controller.dart';
import 'package:hoot/models/feed_join_request.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeAuthService extends GetxService implements AuthService {
  final U? user;
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

class FakeFeedService implements BaseFeedService {
  PostPage? nextPage;
  @override
  Future<PostPage> fetchSubscribedPosts(
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    return PostPage(posts: []);
  }

  @override
  Future<PostPage> fetchFeedPosts(String feedId,
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    return nextPage ?? PostPage(posts: []);
  }
}

class FakeSubscriptionService extends SubscriptionService {
  final Set<String> subs;
  FakeSubscriptionService(this.subs)
      : super(firestore: FakeFirebaseFirestore());
  @override
  Future<Set<String>> fetchSubscriptions(String userId) async => subs;
}

class FakeFeedRequestService extends FeedRequestService {
  bool existsResult = false;
  FakeFeedRequestService()
      : super(
            firestore: FakeFirebaseFirestore(),
            subscriptionService:
                SubscriptionService(firestore: FakeFirebaseFirestore()),
            authService: FakeAuthService(null));
  @override
  Future<List<FeedJoinRequest>> fetchRequests(String feedId) async => [];
  @override
  Future<void> submit(String feedId, String userId) async {}
  @override
  Future<void> accept(String feedId, String userId) async {}
  @override
  Future<void> reject(String feedId, String userId) async {}
  @override
  Future<bool> exists(String feedId, String userId) async => existsResult;
  @override
  Future<int> pendingRequestCount() async => 0;
  @override
  Future<List<FeedJoinRequest>> fetchRequestsForMyFeeds() async => [];
}

class FakeSubscriptionManager extends SubscriptionManager {
  final SubscriptionResult result;
  final List<List<String>> calls = [];
  FakeSubscriptionManager(this.result)
      : super(
          firestore: FakeFirebaseFirestore(),
          subscriptionService:
              SubscriptionService(firestore: FakeFirebaseFirestore()),
          feedRequestService: FeedRequestService(
              firestore: FakeFirebaseFirestore(),
              subscriptionService:
                  SubscriptionService(firestore: FakeFirebaseFirestore()),
              authService: FakeAuthService(null)),
        );
  @override
  Future<SubscriptionResult> toggle(String feedId, U user) async {
    calls.add([feedId, user.uid]);
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onInit sets nsfw warning when not subscribed', () async {
    final auth = FakeAuthService(U(uid: 'u1'));
    final feedService = FakeFeedService();
    final subService = FakeSubscriptionService({});
    final requestService = FakeFeedRequestService();
    final manager = FakeSubscriptionManager(SubscriptionResult.subscribed);
    final controller = FeedPageController(
      args: FeedPageArgs(
          feed: Feed(
              id: 'f1',
              userId: 'u2',
              nsfw: true,
              title: 't',
              description: 'd')),
      authService: auth,
      feedService: feedService,
      subscriptionService: subService,
      feedRequestService: requestService,
      subscriptionManager: manager,
    );
    controller.onInit();
    expect(controller.showNsfwWarning.value, isTrue);
  });

  test('toggleSubscription updates requested state', () async {
    final user = U(uid: 'u1');
    final auth = FakeAuthService(user);
    final feedService = FakeFeedService();
    final subService = FakeSubscriptionService({});
    final requestService = FakeFeedRequestService();
    final manager = FakeSubscriptionManager(SubscriptionResult.requested);
    final controller = FeedPageController(
      args: FeedPageArgs(
          feed: Feed(id: 'f1', userId: 'u2', title: 't', description: 'd')),
      authService: auth,
      feedService: feedService,
      subscriptionService: subService,
      feedRequestService: requestService,
      subscriptionManager: manager,
    );
    controller.onInit();
    await controller.toggleSubscription();
    expect(manager.calls.length, 1);
    expect(controller.requested.value, isTrue);
  });

  test('fetchNext loads posts into state', () async {
    final user = U(uid: 'u1');
    final auth = FakeAuthService(user);
    final feedService = FakeFeedService();
    feedService.nextPage =
        PostPage(posts: [Post(id: 'p1', user: user, text: 'hello')]);
    final controller = FeedPageController(
      args: FeedPageArgs(
          feed: Feed(id: 'f1', userId: 'u2', title: 't', description: 'd')),
      authService: auth,
      feedService: feedService,
      subscriptionService: FakeSubscriptionService({}),
      feedRequestService: FakeFeedRequestService(),
      subscriptionManager:
          FakeSubscriptionManager(SubscriptionResult.subscribed),
    );
    controller.onInit();
    await controller.fetchNext();
    expect(controller.state.value.pages?.isNotEmpty, isTrue);
    expect(controller.state.value.pages!.first.first.text, 'hello');
  });
}

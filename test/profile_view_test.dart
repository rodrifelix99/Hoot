import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:hoot/components/url_preview_component.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/pages/profile/views/profile_view.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/feed_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  final headers = _FakeHttpHeaders();

  @override
  Encoding encoding = utf8;

  @override
  Uri get uri => Uri();

  @override
  void add(List<int> data) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {}

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final _content = utf8.encode('<html></html>');

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _content.length;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  X509Certificate? get certificate => null;

  @override
  List<Cookie> get cookies => [];

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  Future<Socket> detachSocket() => throw UnimplementedError();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_content]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  noSuchMethod(Invocation invocation) => null;
}

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
  Future<void> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<U?> refreshUser() async => _user;

  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}
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

  testWidgets('ProfileView shows profile information', (tester) async {
    final user = U(
      uid: '1',
      name: 'Tester',
      username: 'tester',
      bio: 'Hello',
      location: 'Berlin, Germany',
      website: 'https://example.com',
      feeds: [
        Feed(id: 'f1', userId: 't', title: 'Feed 1', description: 'desc')
      ],
    );
    final service = FakeAuthService(user);
    final subscriptionService =
        SubscriptionService(firestore: FakeFirebaseFirestore());
    final feedRequestService = FeedRequestService(
      firestore: FakeFirebaseFirestore(),
      subscriptionService: subscriptionService,
      authService: service,
    );
    final subscriptionManager = SubscriptionManager(
      firestore: FakeFirebaseFirestore(),
      subscriptionService: subscriptionService,
      feedRequestService: feedRequestService,
    );
    final controller = ProfileController(
      authService: service,
      feedService: FakeFeedService(),
      subscriptionService: subscriptionService,
      feedRequestService: feedRequestService,
      subscriptionManager: subscriptionManager,
    );
    controller.feeds.assignAll(user.feeds ?? []);
    Get.put<AuthService>(service);
    Get.put<SubscriptionService>(subscriptionService);
    Get.put<FeedRequestService>(feedRequestService);
    Get.put<SubscriptionManager>(subscriptionManager);
    Get.put<ProfileController>(controller, tag: 'current');

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(const GetMaterialApp(
        home: Scaffold(body: ProfileView()),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }, createHttpClient: (context) => _FakeHttpClient());

    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('@tester'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Berlin, Germany'), findsOneWidget);
    expect(find.byType(UrlPreviewComponent), findsOneWidget);
  });
}

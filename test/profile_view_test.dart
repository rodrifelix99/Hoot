import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/pages/profile/views/profile_view.dart';
import 'package:hoot/services/auth_service.dart';
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
  Future<void> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
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
  Future<PostPage> fetchFeedPosts(String feedId, {DocumentSnapshot? startAfter, int limit = 10}) async {
    return PostPage(posts: []);
  }
}

void main() {
  testWidgets('ProfileView shows profile information', (tester) async {
    final user = U(
      uid: '1',
      name: 'Tester',
      username: 'tester',
      bio: 'Hello',
      feeds: [Feed(id: 'f1', userId: 't', title: 'Feed 1', description: 'desc')],
    );
    final service = FakeAuthService(user);
    final controller = ProfileController(
      authService: service,
      feedService: FakeFeedService(),
    );
    Get.put<AuthService>(service);
    Get.put<ProfileController>(controller);

    await tester.pumpWidget(const GetCupertinoApp(
      home: CupertinoPageScaffold(child: ProfileView()),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('@tester'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Feed 1'), findsOneWidget);
  });
}

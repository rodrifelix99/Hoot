import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'package:hoot/pages/create_post/views/create_post_view.dart';
import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/storage_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/news_service.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:hoot/util/enums/feed_types.dart';

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
  @override
  bool get isStaff => throw UnimplementedError();
}

class FakeStorageService extends GetxService implements BaseStorageService {
  @override
  Future<List<UploadedPostImage>> uploadPostImages(
          String postId, List<File> files) async =>
      [];
}

class FakeNewsService implements BaseNewsService {
  final List<NewsItem> items;
  FakeNewsService(this.items);
  @override
  Future<List<NewsItem>> fetchTrendingNews({String? topic}) async => items;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  testWidgets('renders dynamic trending title', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final postService = PostService(firestore: firestore);
    final feed = Feed(
      id: 'f1',
      userId: 'u1',
      title: 't',
      description: 'd',
      color: Colors.blue,
      order: 0,
      type: FeedType.technology,
    );
    final auth = FakeAuthService(U(
        uid: 'u1',
        name: 'Tester',
        username: 'tester',
        smallProfilePictureUrl: 'a.png',
        feeds: [feed]));
    final controller = CreatePostController(
        postService: postService,
        authService: auth,
        userId: 'u1',
        storageService: FakeStorageService(),
        newsService: FakeNewsService(
            [NewsItem(title: 'News 1', link: 'https://a.com')]));
    Get.put(controller);
    controller.selectedFeeds.assignAll([feed]);
    await tester.pumpWidget(Portal(
      child: GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const CreatePostView(),
      ),
    ));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Trending in Technology'), findsOneWidget);
    expect(find.text('News 1'), findsOneWidget);
    Get.reset();
  }, skip: true);
}

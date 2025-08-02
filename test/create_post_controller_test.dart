import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toastification/toastification.dart';

import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:get/get.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/storage_service.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart';
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

class FakeStorageService extends GetxService implements BaseStorageService {
  List<List<File>> calls = [];

  @override
  Future<List<UploadedPostImage>> uploadPostImages(
      String postId, List<File> files) async {
    calls.add(files);
    return files
        .map((f) => UploadedPostImage(
            url: 'https://example.com/${f.path.split('/').last}',
            blurHash: 'hash'))
        .toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreatePostController', () {
    testWidgets('publish fails when no feed is selected', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage);
      controller.textController.text = 'Hello';
      expect(await controller.publish(), isNull);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('publish fails when text exceeds 280 chars', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage);
      controller.textController.text = 'a' * 281;
      controller.selectedFeed.value = Feed(
          id: 'f1',
          userId: 't',
          title: 't',
          description: 'd',
          color: Colors.blue);
      expect(await controller.publish(), isNull);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('successful publish writes document', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage);
      controller.selectedFeed.value = Feed(
          id: 'f1',
          userId: 't',
          title: 't',
          description: 'd',
          color: Colors.blue);
      controller.textController.text = 'Hi';
      final result = await controller.publish();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(result, isA<Post>());
      final posts = await firestore.collection('posts').get();
      expect(posts.docs.length, 1);
      final data = posts.docs.first.data();
      expect(data['text'], 'Hi');
      expect(data['user']['displayName'], 'Tester');
      expect(data['user']['username'], 'tester');
      expect(data['user']['smallAvatar'], 'a.png');
      expect(data['feed']['title'], 't');
    });

    testWidgets('images are uploaded and urls stored', (tester) async {
      await tester.pumpWidget(const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: SizedBox())),
      ));
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [
            Feed(
                id: 'f1',
                userId: 'u1',
                title: 't',
                description: 'd',
                color: Colors.blue)
          ]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage);

      controller.selectedFeed.value = Feed(
          id: 'f1',
          userId: 't',
          title: 't',
          description: 'd',
          color: Colors.blue);
      final file = File('${Directory.systemTemp.path}/img.jpg')
        ..writeAsBytesSync([0]);
      addTearDown(() => file.deleteSync());
      controller.imageFiles.add(file);
      controller.textController.text = 'Hi';
      final result = await controller.publish();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(result, isA<Post>());
      expect(storage.calls.length, 1);
      final posts = await firestore.collection('posts').get();
      expect(
          posts.docs.first.data()['images'][0], 'https://example.com/img.jpg');
      expect(posts.docs.first.data()['hashes'][0], 'hash');
    });

    testWidgets('available feeds loaded on init', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final postService = PostService(
        firestore: firestore,
      );
      final feed = Feed(
          id: 'f1',
          userId: 'u1',
          title: 't',
          description: 'd',
          color: Colors.blue);
      final auth = FakeAuthService(U(
          uid: 'u1',
          name: 'Tester',
          username: 'tester',
          smallProfilePictureUrl: 'a.png',
          feeds: [feed]));
      final storage = FakeStorageService();
      final controller = CreatePostController(
          postService: postService,
          authService: auth,
          userId: 'u1',
          storageService: storage);
      Get.put(controller);
      await tester.pump();
      expect(controller.availableFeeds.length, 1);
      expect(controller.availableFeeds.first.id, 'f1');
      Get.reset();
    });
  });
}

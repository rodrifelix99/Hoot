import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:hoot/pages/create_post/views/create_post_view.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/storage_service.dart';

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

class FakeStorageService extends GetxService implements BaseStorageService {
  @override
  Future<List<String>> uploadPostImages(String postId, List<File> files) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('media buttons remain visible with media selected', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final postService = PostService(firestore: firestore);
    final auth = FakeAuthService(U(uid: 'u1'));
    final storage = FakeStorageService();
    final controller =
        CreatePostController(postService: postService, authService: auth, userId: 'u1', storageService: storage);
    controller.availableFeeds.assignAll([Feed(id: 'f1', userId: 'u1', title: 't', description: 'd')]);
    Get.put<AuthService>(auth);
    Get.put<CreatePostController>(controller);

    FlutterError.onError = (details) {};
    addTearDown(() {
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });

    await tester.pumpWidget(const GetCupertinoApp(
      home: CupertinoPageScaffold(child: CreatePostView()),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.image), findsOneWidget);
    expect(find.byIcon(Icons.gif_box), findsOneWidget);

    controller.pickGif('https://example.com/g.gif');
    await tester.pump();

    final imageButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.image));
    expect(imageButton.onPressed, isNull);
    expect(find.byIcon(Icons.gif_box), findsOneWidget);

    controller.gifUrl.value = null;
    final bytes = File('assets/logo.png').readAsBytesSync();
    final tempDir = Directory.systemTemp;
    final files = List.generate(4, (i) {
      final file = File('${tempDir.path}/img$i.png');
      file.writeAsBytesSync(bytes);
      return file;
    });
    controller.imageFiles.assignAll(files);
    await tester.pump();

    final gifButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.gif_box));
    expect(gifButton.onPressed, isNull);

    for (final f in files) {
      if (f.existsSync()) f.deleteSync();
    }
    Get.reset();
  });
}

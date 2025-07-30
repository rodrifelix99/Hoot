import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:toastification/toastification.dart';

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

  @override
  Future<U?> refreshUser() async => _user;
  
  @override
  Future<void> createUserDocumentIfNeeded(User user) async {}
}

class FakePostService extends GetxService implements BasePostService {
  int callCount = 0;
  Post? lastOriginal;
  Feed? lastFeed;
  U? lastUser;

  @override
  String newPostId() => 'n1';

  @override
  Future<void> createPost(Map<String, dynamic> data, {String? id}) async {}

  @override
  Future<void> toggleLike(String postId, String userId, bool like) async {}

  @override
  Future<Post?> fetchPost(String id) async => null;

  @override
  Future<String> reFeed(
      {required Post original,
      required Feed targetFeed,
      required U user}) async {
    callCount++;
    lastOriginal = original;
    lastFeed = targetFeed;
    lastUser = user;
    return 'n1';
  }

  @override
  Future<void> deletePost(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selecting feed reFeeds post', (tester) async {
    final feed = Feed(
      id: 'f1',
      userId: 'u1',
      title: 'feed',
      description: 'd',
      color: Colors.blue,
    );
    final user = U(uid: 'u1', feeds: [feed]);
    final auth = FakeAuthService(user);
    final service = FakePostService();

    Get.put<AuthService>(auth);
    Get.put<BasePostService>(service);

    final post = Post(id: 'p1', text: 'Hi');

    await tester.pumpWidget(
      ToastificationWrapper(
        child: GetMaterialApp(
          home: Scaffold(body: PostComponent(post: post, postService: service)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(SolarIconsOutline.refreshSquare));
    await tester.pumpAndSettle();

    await tester.tap(find.text(feed.title));
    await tester.pumpAndSettle();

    // Wait for toast to dismiss
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(service.callCount, 1);
    expect(service.lastOriginal?.id, 'p1');
    expect(service.lastFeed?.id, 'f1');
    expect(service.lastUser?.uid, 'u1');

    Get.reset();
  });

  testWidgets('reFeeded post shows indicator', (tester) async {
    final post = Post(id: 'p1', text: 'Hi', reFeeded: true);
    final auth = FakeAuthService(U(uid: 'u1'));
    final service = FakePostService();

    Get.put<AuthService>(auth);
    Get.put<BasePostService>(service);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: PostComponent(post: post)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('ReHoot'), findsOneWidget);
    Get.reset();
  });
}

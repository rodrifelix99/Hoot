
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/pages/home/views/home_view.dart';
import 'package:hoot/pages/home/controllers/home_controller.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/feed_request_service.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/theme_service.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed_join_request.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:solar_icons/solar_icons.dart';

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
  // TODO: implement isStaff
  bool get isStaff => throw UnimplementedError();
}

class FakeFeedRequestService extends FeedRequestService {
  FakeFeedRequestService()
      : super(
            firestore: FakeFirebaseFirestore(),
            subscriptionService:
                SubscriptionService(firestore: FakeFirebaseFirestore()),
            authService: FakeAuthService(U(uid: 'owner')));

  @override
  Future<int> pendingRequestCount() async => 0;

  @override
  Future<List<FeedJoinRequest>> fetchRequestsForMyFeeds() async => [];
}

class TestNotificationsController extends NotificationsController {
  TestNotificationsController()
      : super(
            authService: FakeAuthService(U(uid: 'u1')),
            notificationService:
                NotificationService(firestore: FakeFirebaseFirestore()),
            feedRequestService: FakeFeedRequestService());
}

void main() {
  testWidgets('swiping left opens create post page', (tester) async {
    final themeService = ThemeService();
    await themeService.loadThemeSettings();
    Get.put(themeService);
    Get.put<AuthService>(FakeAuthService(U(uid: 'u1', username: 't')));
    Get.put(HomeController());
    Get.put<NotificationsController>(TestNotificationsController());

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        getPages: [
          GetPage(name: '/', page: () => const HomeView()),
          GetPage(
            name: AppRoutes.createPost,
            page: () => const Scaffold(body: Text('create post page')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(HomeView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('create post page'), findsOneWidget);
    Get.reset();
  });

  testWidgets('tapping bottom bar icon triggers haptic feedback',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );

    final themeService = ThemeService();
    await themeService.loadThemeSettings();
    Get.put(themeService);
    Get.put<AuthService>(FakeAuthService(U(uid: 'u1', username: 't')));
    Get.put(HomeController());
    Get.put<NotificationsController>(TestNotificationsController());

    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(SolarIconsOutline.compass));
    await tester.pump();

    expect(calls.any((c) => c.method == 'HapticFeedback.vibrate'), isTrue);

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    Get.reset();
  });
}

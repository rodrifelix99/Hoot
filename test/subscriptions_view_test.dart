import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hoot/pages/subscriptions/controllers/subscriptions_controller.dart';
import 'package:hoot/pages/subscriptions/views/subscriptions_view.dart';
import 'package:hoot/services/subscription_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/translations/app_translations.dart';
import 'package:hoot/models/user.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SubscriptionsView shows subscribed feeds', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('feeds').doc('f1').set({
      'title': 'Feed 1',
      'description': 'd',
      'color': '0',
      'userId': 'u1',
      'subscriberCount': 1,
    });
    await firestore.collection('users').doc('u1').set({'uid': 'u1'});
    await firestore
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .doc('f1')
        .set({'createdAt': Timestamp.now()});
    final auth = FakeAuthService(U(uid: 'u1'));
    final service = SubscriptionService(
      firestore: firestore,
    );
    final controller = SubscriptionsController(
      authService: auth,
      subscriptionService: service,
    );
    Get.put<AuthService>(auth);
    Get.put<SubscriptionsController>(controller);

    await tester.pumpWidget(GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en'),
      home: const SubscriptionsView(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Feed 1'), findsOneWidget);

    Get.reset();
  });

  testWidgets('tapping unsubscribe removes feed', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('feeds').doc('f1').set({
      'title': 'Feed 1',
      'description': 'd',
      'color': '0',
      'userId': 'u1',
      'subscriberCount': 1,
    });
    await firestore.collection('users').doc('u1').set({'uid': 'u1'});
    await firestore
        .collection('users')
        .doc('u1')
        .collection('subscriptions')
        .doc('f1')
        .set({'createdAt': Timestamp.now()});
    final auth = FakeAuthService(U(uid: 'u1'));
    final service = SubscriptionService(
      firestore: firestore,
    );
    final controller = SubscriptionsController(
      authService: auth,
      subscriptionService: service,
    );
    Get.put<AuthService>(auth);
    Get.put<SubscriptionsController>(controller);

    await tester.pumpWidget(GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en'),
      home: const SubscriptionsView(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();

    expect(find.text('Feed 1'), findsNothing);

    Get.reset();
  });
}

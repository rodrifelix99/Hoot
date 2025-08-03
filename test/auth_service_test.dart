import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'package:hoot/services/auth_service.dart';

void main() {
  test('createUserDocumentIfNeeded sets default scores', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final service = AuthService(auth: auth, firestore: firestore);
    final user = MockUser(uid: 'u1', displayName: 'John');

    await service.createUserDocumentIfNeeded(user);

    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.get('activityScore'), 0);
    expect(doc.get('popularityScore'), 0);
    expect(doc.get('role'), 'user');
  });

  test('signInWithGoogle writes displayName into Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final auth =
        StubFirebaseAuth(mockUser: MockUser(uid: 'u1', displayName: 'John'));
    final service = AuthService(auth: auth, firestore: firestore);

    final originalPlatform = GoogleSignInPlatform.instance;
    GoogleSignInPlatform.instance = FakeGoogleSignInPlatform(
      user: GoogleSignInUserData(
        email: 'john@example.com',
        id: 'u1',
        displayName: 'John',
      ),
      tokens: GoogleSignInTokenData(
        idToken: 'id-token',
        accessToken: 'access-token',
      ),
    );
    addTearDown(() {
      GoogleSignInPlatform.instance = originalPlatform;
    });

    await service.signInWithGoogle();

    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.get('displayName'), 'John');
  });
}

class FakeGoogleSignInPlatform extends GoogleSignInPlatform {
  FakeGoogleSignInPlatform({this.user, required this.tokens});

  final GoogleSignInUserData? user;
  final GoogleSignInTokenData tokens;

  @override
  bool get isMock => true;

  @override
  Future<void> init({
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
    String? hostedDomain,
    String? clientId,
  }) async {}

  @override
  Future<GoogleSignInUserData?> signInSilently() async => user;

  @override
  Future<GoogleSignInUserData?> signIn() async => user;

  @override
  Future<GoogleSignInTokenData> getTokens({
    required String email,
    bool? shouldRecoverAuth,
  }) async =>
      tokens;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<bool> isSignedIn() async => user != null;

  @override
  Future<void> clearAuthCache({required String token}) async {}

  @override
  Future<bool> requestScopes(List<String> scopes) async => true;

  @override
  Future<bool> canAccessScopes(List<String> scopes,
          {String? accessToken}) async =>
      true;
}

class FakeUserCredential implements UserCredential {
  FakeUserCredential(this._user);

  final MockUser _user;

  @override
  User get user => _user;

  @override
  AdditionalUserInfo? get additionalUserInfo =>
      AdditionalUserInfo(isNewUser: true);

  @override
  AuthCredential? get credential => null;
}

class StubFirebaseAuth extends MockFirebaseAuth {
  StubFirebaseAuth({required MockUser mockUser})
      : _user = mockUser,
        super(mockUser: mockUser);

  final MockUser _user;

  @override
  Future<UserCredential> signInWithCredential(
      AuthCredential? credential) async {
    return FakeUserCredential(_user);
  }
}

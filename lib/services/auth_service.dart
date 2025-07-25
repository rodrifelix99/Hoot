import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user.dart';

/// Provides authentication helpers for the application.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  U? _currentUser;
  bool _fetched = false;

  /// Returns the cached [U] if available or fetches it from Firestore.
  Future<U?> fetchUser() async {
    if (_fetched) return _currentUser;
    _fetched = true;
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _currentUser = null;
      return null;
    }

    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      _currentUser = U.fromJson(doc.data()!);
      final subs = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('subscriptions')
          .get();
      _currentUser!.subscriptionCount = subs.docs.length;
    } else {
      _currentUser = null;
    }
    return _currentUser;
  }

  U? get currentUser => _currentUser;

  /// Creates a Firestore document for [user] if none exists.
  Future<void> _createUserDocumentIfNeeded(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists) return;
    await docRef.set({
      'uid': user.uid,
      'displayName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Signs out the current user and clears cached data.
  Future<void> signOut() async {
    _currentUser = null;
    _fetched = false;
    await _auth.signOut();
  }

  /// Signs in the user using Google authentication.
  Future<UserCredential> signInWithGoogle() async {
    final user = await GoogleSignIn().signIn();
    if (user == null) {
      throw FirebaseAuthException(
        code: 'ABORTED',
        message: 'Google sign in aborted',
      );
    }

    final googleAuth = await user.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    if (result.additionalUserInfo?.isNewUser ?? false) {
      final firebaseUser = result.user;
      if (firebaseUser != null) {
        await _createUserDocumentIfNeeded(firebaseUser);
      }
    }
    _fetched = false;
    await fetchUser();
    return result;
  }

  /// Signs in the user using Apple authentication.
  Future<UserCredential> signInWithApple() async {
    final appleIDCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleIDCredential.identityToken,
      accessToken: appleIDCredential.authorizationCode,
    );
    final result = await _auth.signInWithCredential(credential);
    if (result.additionalUserInfo?.isNewUser ?? false) {
      final firebaseUser = result.user;
      if (firebaseUser != null) {
        await _createUserDocumentIfNeeded(firebaseUser);
      }
    }
    _fetched = false;
    await fetchUser();
    return result;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Provides authentication helpers for the application.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a Firestore document for [user] if none exists.
  static Future<void> _createUserDocumentIfNeeded(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists) return;
    await docRef.set({
      'uid': user.uid,
      'displayName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Signs out the current user.
  static Future<void> signOut() => _auth.signOut();

  /// Signs in the user using Google authentication.
  static Future<UserCredential> signInWithGoogle() async {
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
    return result;
  }

  /// Signs in the user using Apple authentication.
  static Future<UserCredential> signInWithApple() async {
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
    return result;
  }
}

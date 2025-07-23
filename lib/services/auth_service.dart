import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Provides authentication helpers for the application.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
    return _auth.signInWithCredential(credential);
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
    return _auth.signInWithCredential(credential);
  }
}

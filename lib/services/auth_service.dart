import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';

/// Provides authentication helpers for the application.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Rxn<U> _currentUser = Rxn<U>();
  bool _fetched = false;

  /// Forces refetch of the current user from Firestore.
  Future<U?> refreshUser() {
    _fetched = false;
    return fetchUser();
  }

  /// Returns the cached [U] if available or fetches it from Firestore.
  Future<U?> fetchUser() async {
    if (_fetched) return _currentUser.value;
    _fetched = true;
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _currentUser.value = null;
      return null;
    }

    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      _currentUser.value = U.fromJson(doc.data()!);
      final subs = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('subscriptions')
          .get();
      _currentUser.value!.subscriptionCount = subs.docs.length;

      final feedsSnapshot = await _firestore
          .collection('feeds')
          .where('userId', isEqualTo: firebaseUser.uid)
          .get();
      _currentUser.value!.feeds = feedsSnapshot.docs
          .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } else {
      _currentUser.value = null;
    }
    return _currentUser.value;
  }

  /// Fetches a user by [uid] from Firestore.
  Future<U?> fetchUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final user = U.fromJson(doc.data()!);
    final subs = await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .get();
    user.subscriptionCount = subs.docs.length;
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: uid)
        .get();
    user.feeds = feedsSnapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList();
    return user;
  }

  /// Fetches a user document by their [username].
  Future<U?> fetchUserByUsername(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final user = U.fromJson(doc.data());
    final subs = await _firestore
        .collection('users')
        .doc(doc.id)
        .collection('subscriptions')
        .get();
    user.subscriptionCount = subs.docs.length;
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: doc.id)
        .get();
    user.feeds = feedsSnapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList();
    return user;
  }

  /// Returns users whose username starts with [query].
  Future<List<U>> searchUsers(String query, {int limit = 5}) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => U.fromJson(d.data())).toList();
  }

  U? get currentUser => _currentUser.value;
  Stream<U?> get currentUserStream => _currentUser.stream;
  Rxn<U> get currentUserRx => _currentUser;

  /// Creates a Firestore document for [user] if none exists.
  Future<void> _createUserDocumentIfNeeded(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists) return;
    await docRef.set({
      'uid': user.uid,
      'displayName': user.displayName,
      'invitationCode': const Uuid().v4().substring(0, 8).toUpperCase(),
      'invitationUses': 0,
      'invitationLastReset': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'activityScore': 0,
      'popularityScore': 0,
    });
  }

  @visibleForTesting
  Future<void> createUserDocumentIfNeeded(User user) =>
      _createUserDocumentIfNeeded(user);

  /// Signs out the current user and clears cached data.
  Future<void> signOut() async {
    _currentUser.value = null;
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

  /// Deletes the current user's account and Firestore data.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    _currentUser.value = null;
    _fetched = false;
  }
}

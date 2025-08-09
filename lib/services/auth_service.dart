import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/analytics_service.dart';

/// Provides authentication helpers for the application.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? displayName;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  final Rxn<U> _currentUser = Rxn<U>();
  bool _fetched = false;
  bool get isStaff => _currentUser.value?.role == UserRole.staff;

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
      final data = doc.data()!;
      _currentUser.value =
          U.fromJson({...data, 'createdAt': data['createdAt']});
      final subs = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('subscriptions')
          .get();
      _currentUser.value!.subscriptionCount = subs.docs.length;

      final feedsSnapshot = await _firestore
          .collection('feeds')
          .where('userId', isEqualTo: firebaseUser.uid)
          .orderBy('order')
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
    final data = doc.data()!;
    final user = U.fromJson({...data, 'createdAt': data['createdAt']});
    final subs = await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .get();
    user.subscriptionCount = subs.docs.length;
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: uid)
        .orderBy('order')
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
        .where('usernameLowercase', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final data = doc.data();
    final user = U.fromJson({...data, 'createdAt': data['createdAt']});
    final subs = await _firestore
        .collection('users')
        .doc(doc.id)
        .collection('subscriptions')
        .get();
    user.subscriptionCount = subs.docs.length;
    final feedsSnapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: doc.id)
        .orderBy('order')
        .get();
    user.feeds = feedsSnapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList();
    return user;
  }

  /// Returns users whose username starts with [query].
  Future<List<U>> searchUsers(String query, {int limit = 5}) async {
    final sw = Stopwatch()..start();
    final q = query.toLowerCase();
    final snapshot = await _firestore
        .collection('users')
        .where('usernameLowercase', isGreaterThanOrEqualTo: q)
        .where('usernameLowercase', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(limit)
        .get();
    final users = snapshot.docs.map((d) => U.fromJson(d.data())).toList();
    if (_analytics != null) {
      await _analytics!.logEvent('search_users', parameters: {
        'query': query,
        'resultCount': users.length,
        'responseTimeMs': sw.elapsedMilliseconds,
      });
    }
    return users;
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
      'role': 'user',
      'invitationCode': const Uuid().v4().substring(0, 8).toUpperCase(),
      'invitationUses': 0,
      'invitationLastReset': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'activityScore': 0,
      'popularityScore': 0,
    });
    if (_analytics != null) {
      await _analytics!.logEvent('sign_up', parameters: {
        'provider': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'unknown',
        'userId': user.uid,
        if (user.displayName != null) 'displayName': user.displayName,
        if (user.email != null) 'email': user.email,
      });
    }
  }

  @visibleForTesting
  Future<void> createUserDocumentIfNeeded(User user) =>
      _createUserDocumentIfNeeded(user);

  /// Signs out the current user and clears cached data.
  Future<void> signOut() async {
    final user = _auth.currentUser;
    final provider = (user?.providerData.isNotEmpty ?? false)
        ? user!.providerData.first.providerId
        : null;
    final uid = user?.uid;
    _currentUser.value = null;
    _fetched = false;
    try {
      await _auth.signOut();
      if (_analytics != null) {
        await _analytics!.logEvent('sign_out', parameters: {
          if (provider != null) 'provider': provider,
          if (uid != null) 'userId': uid,
        });
      }
    } catch (e) {
      if (_analytics != null) {
        await _analytics!.logEvent('sign_out_error', parameters: {
          if (provider != null) 'provider': provider,
          if (uid != null) 'userId': uid,
          'error': e.toString(),
        });
      }
      rethrow;
    }
  }

  /// Signs in the user using Google authentication.
  Future<UserCredential> signInWithGoogle() async {
    const provider = 'google';
    try {
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

      final displayName = result.user?.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        this.displayName = displayName;
      }
      _fetched = false;
      await fetchUser();
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in', parameters: {
          'provider': provider,
          if (result.user != null) 'userId': result.user!.uid,
        });
      }
      return result;
    } catch (e) {
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in_error', parameters: {
          'provider': provider,
          'error': e.toString(),
        });
      }
      rethrow;
    }
  }

  /// Signs in the user using Apple authentication.
  Future<UserCredential> signInWithApple() async {
    const provider = 'apple';
    try {
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

      final displayName = result.user?.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        this.displayName = displayName;
      }
      _fetched = false;
      await fetchUser();
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in', parameters: {
          'provider': provider,
          if (result.user != null) 'userId': result.user!.uid,
        });
      }
      return result;
    } catch (e) {
      if (_analytics != null) {
        await _analytics!.logEvent('sign_in_error', parameters: {
          'provider': provider,
          'error': e.toString(),
        });
      }
      rethrow;
    }
  }

  /// Deletes the current user's account and Firestore data.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
    _currentUser.value = null;
    _fetched = false;
  }
}

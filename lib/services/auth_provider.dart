import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hoot/models/user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hoot/models/notification.dart' as n;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  U? _user;
  U? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged); // Add listener
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        _user = null;
      } else if (_user == null || (_user!.uid != firebaseUser.uid && _user!.uid != 'HOOT-IS-AWESOME')) {
        _user = await getUserInfo();
      } else {
        _user = U(uid: firebaseUser.uid);
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get isSignedIn => _auth.currentUser != null;

  Future<U?> getUserInfo() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('getUserInfo');
      final response = await callable.call();
      final json = response.data;
      return U.fromJson(json);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> signInWithApple() async {
    try {
      _user = U(uid: 'HOOT-IS-AWESOME');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        print('User is null');
        return "unknown-error";
      } else if (userCredential.additionalUserInfo!.isNewUser) {
        notifyListeners();
        return "new-user";
      } else {
        _user = await getUserInfo();
        notifyListeners();
        return "success";
      }

    } catch (e) {
      print(e.toString());
      _user = null;
      FirebaseAuthException exception = e as FirebaseAuthException;
      return exception.code;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        print('User is null');
        return false;
      } else if (userCredential.additionalUserInfo!.isNewUser) {
        _user = U(uid: 'HOOT-IS-AWESOME');
        notifyListeners();
        return true;
      } else {
        _user = await getUserInfo();
        notifyListeners();
        return true;
      }

    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _user = await getUserInfo();
        notifyListeners();
        return "success";
      } else if (userCredential.additionalUserInfo!.isNewUser || userCredential.user!.displayName == null) {
        _user = U(uid: 'HOOT-IS-AWESOME');
        notifyListeners();
        return "new-user";
      } else {
        return "unknown-error";
      }
    } catch (e) {
      print(e.toString());
      FirebaseAuthException exception = e as FirebaseAuthException;
      return exception.code;
    }
  }

  Future<String> signUpWithEmailAndPassword(String email, String password) async {
    try {
      _user = U(uid: 'HOOT-IS-AWESOME');
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        notifyListeners();
        return "success";
      } else {
        _user = null;
        return "unknown-error";
      }
    } catch (e) {
      _user = null;
      FirebaseAuthException exception = e as FirebaseAuthException;
      return exception.code;
    }
  }

  Future<bool> updateUser(U user) async {
    try {
      U? oldUser = _user;
      _user = user;
      notifyListeners();

      HttpsCallable callable = _functions.httpsCallable('updateUser');
      final response = await callable.call(user.toJson());

      if (response.data == true) {
        return true;
      } else {
        _user = oldUser;
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('isUsernameAvailable');
      final response = await callable.call(username);
      return response.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> setFCMToken(String token) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('setFCMToken');
      final response = await callable.call(token);
      return response.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<U>> getSuggestions() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('getSuggestedUsers');
      final response = await callable.call();
      final data = response.data;

      if (data != null && data is List) {
        final List<U> users = data.map<U>((user) => U.fromJson(Map<String, dynamic>.from(user))).toList();
        return users;
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> isFollowing(String uid) async {
    try {
      if (_user!.following.contains(uid)) {
        return true;
      } else {
        HttpsCallable callable = _functions.httpsCallable('isFollowing');
        final response = await callable.call(uid);
        return response.data;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> follow(String uid) async {
    try {
      _user!.following.add(uid);
      HttpsCallable callable = _functions.httpsCallable('followUser');
      final response = await callable.call(uid);
      if (response.data == true) {
        return true;
      } else {
        _user!.following.remove(uid);
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> unfollow(String uid) async {
    try {
      _user!.following.remove(uid);
      HttpsCallable callable = _functions.httpsCallable('unfollowUser');
      final response = await callable.call(uid);
      if (response.data == true) {
        return true;
      } else {
        _user!.following.add(uid);
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<U>> getFollows(String userId, bool following) async {
    try {
      HttpsCallable callable = _functions.httpsCallable(following ? 'getFollowing' : 'getFollowers');
      final response = await callable.call(userId);
      final data = response.data;

      if (data != null && data is List) {
        final List<U> users = data.map<U>((user) => U.fromJson(Map<String, dynamic>.from(user))).toList();
        return users;
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<U>> searchUsers(String query) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('searchUsers');
      final response = await callable.call(query);
      final data = response.data;

      if (data != null && data is List) {
        final List<U> users = data.map<U>((user) => U.fromJson(Map<String, dynamic>.from(user))).toList();
        return users;
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<int> countUnreadNotifications() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('countUnreadNotifications');
      final response = await callable.call();
      final data = response.data;

      if (data != null && data is int) {
        return data;
      } else {
        return 0;
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future<List<n.Notification>> getNotifications() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('getNotifications');
      final response = await callable.call();
      final data = response.data;

      if (data != null && data is List) {
        final List<n.Notification> notifications = data.map<n.Notification>((notification) => n.Notification.fromJson(Map<String, dynamic>.from(notification))).toList();
        return notifications;
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}
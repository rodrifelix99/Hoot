import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hoot/models/notification.dart' as n;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  U? _user;
  U? get user => _user;

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  PhoneNumber get phoneNumber => _phoneNumber;
  set phoneNumber(PhoneNumber phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  String? _verificationId;
  String? get verificationId => _verificationId;

  int _notificationsCount = 0;
  int get notificationsCount => _notificationsCount;

  List<U> _userSuggestions = [];
  List<U> get userSuggestions => _userSuggestions;
  set userSuggestions(List<U> userSuggestions) {
    _userSuggestions = userSuggestions;
    notifyListeners();
  }

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged); // Add listener
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        _user = null;
      } else if (_user == null || (_user!.uid != firebaseUser.uid && _user!.uid != 'HOOT-IS-AWESOME')) {
        _user = await getUserInfo() ?? U(uid: firebaseUser.uid);
      } else {
        _user = U(uid: firebaseUser.uid);
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  void notify() {
    notifyListeners();
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

  Future verifyPhoneNumber() async {
    try {
      _auth.verifyPhoneNumber(
          phoneNumber: _phoneNumber.phoneNumber!,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async { },
          verificationFailed: (FirebaseAuthException e) {
            print(e.toString());
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            notifyListeners();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
            notifyListeners();
          },
      );
    } catch (e) {
      print(e.toString());
      FirebaseAuthException exception = e as FirebaseAuthException;
      throw exception.code;
    }
  }

  Future<String> signInWithPhoneCredential(String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return "unknown-error";
      } else if (userCredential.additionalUserInfo!.isNewUser) {
        _user = U(uid: 'HOOT-IS-AWESOME');
        notifyListeners();
        return "new-user";
      } else {
        _user = await getUserInfo();
        notifyListeners();
        return "success";
      }
    } catch (e) {
      print(e.toString());
      FirebaseAuthException error = e as FirebaseAuthException;
      return error.code;
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

  Future countUnreadNotifications() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('countUnreadNotifications');
      final response = await callable.call();
      final data = response.data;

      if (data != null && data is int) {
        _notificationsCount = data;
      } else {
        _notificationsCount = 0;
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<n.Notification>> getNotifications(DateTime startAt) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('getNotifications');
      final response = await callable.call({
        'startAfter': startAt.toIso8601String(), // Convert DateTime to a string representation
      });
      final decodedData = jsonDecode(response.data);
      final List<dynamic> data = decodedData is List<dynamic> ? decodedData : [];
      return data.map<n.Notification>((notification) => n.Notification.fromJson(notification as Map<String, dynamic>)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future markNotificationsAsRead() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('markNotificationsRead');
      await callable.call();
      _notificationsCount = 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<int> getSubscriptionsCount(String userId) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('getSubscriptionsCount');
      final response = await callable.call({
        'uid': userId,
      });
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

  Future<bool> deleteAccount() async {
    try {
      HttpsCallable callable = _functions.httpsCallable('deleteAccount');
      final response = await callable.call();
      return response.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void addFeedToUser(Feed feed) {
    _user!.feeds?.insert(0, feed);
    notifyListeners();
  }

  void addAllFeedsToUser(List<Feed> feeds) {
    _user!.feeds?.insertAll(0, feeds);
    notifyListeners();
  }

  void removeFeedFromUser(String feedId) {
    _user!.feeds?.removeWhere((feed) => feed.id == feedId);
    notifyListeners();
  }

  Future<List<U>> getContacts(List<String> contacts) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('getContacts');
      final response = await callable.call(contacts);
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

}
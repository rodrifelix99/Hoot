import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';

class FeedProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  List<Post> _mainFeedPosts = [];
  List<Post> get mainFeedPosts => _mainFeedPosts;

  Future<bool> createPost(context, {required String feedId, String? text, List<String>? media}) async {
    try {
      AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
      Post post = Post(
        id: '',
        text: text,
        media: media,
        feedId: feedId
      );
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createPost');
      await callable.call(post.toJson());
      post.user = authProvider.user;
      post.feed = authProvider.user?.feeds?.firstWhere((f) => f.id == feedId) ?? Feed(id: feedId, title: 'Posted just now', description: '', icon: '', color: Colors.white, private: false, nsfw: false);
      mainFeedPosts.insert(0, post);
      authProvider.user?.feeds != null ? authProvider.user?.feeds?.firstWhere((f) => f.id == feedId).posts?.insert(0, post) : null;
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deletePost(BuildContext context, String postId, String feedId) async {
    try {
      AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
      _mainFeedPosts.removeWhere((post) => post.id == postId);
      authProvider.user?.feeds != null ? authProvider.user?.feeds?.firstWhere((f) => f.id == feedId).posts?.removeWhere((post) => post.id == postId) : null;
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('deletePost');
      await callable.call({'postId': postId, 'feedId': feedId});
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<String> createFeed(BuildContext context,
      {required String title,
      required String description,
      required String icon,
      required Color color,
      required bool private,
      required bool nsfw }) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createFeed');
      final res = await callable.call({
        'title': title,
        'description': description,
        'icon': icon,
        'color': color.value.toString(),
        'private': private,
        'nsfw': nsfw
      });
      Feed feed = Feed(id: res.data, title: title, description: description, icon: icon, color: color, private: private, nsfw: nsfw);
      Provider.of<AuthProvider>(context, listen: false).addFeedToUser(feed);
      return res.data;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  Future<bool> editFeed(BuildContext context, Feed feed) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('editFeed');
      final res = await callable.call({
        'feedId': feed.id,
        'title': feed.title,
        'description': feed.description,
        'icon': feed.icon,
        'color': feed.color?.value.toString(),
        'private': feed.private,
        'nsfw': feed.nsfw
      });
      Provider.of<AuthProvider>(context, listen: false).user?.feeds?.removeWhere((f) => f.id == feed.id);
      Provider.of<AuthProvider>(context, listen: false).addFeedToUser(feed);
      return res.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<Feed>> getFeeds(String uid) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeeds');
      final res = await callable.call({'uid': uid});
      List<Feed> feeds = [];
      print(res.data);
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var feed in responseData) {
          feeds.add(Feed.fromJson(feed));
        }
      }
      return feeds;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<void> getMainFeed(DateTime startAfter, bool refresh) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getMainFeedPosts');
      final res = await callable.call({'startAfter': startAfter.millisecondsSinceEpoch});
      List<Post> posts = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var post in responseData) {
          posts.add(Post.fromJson(post));
        }
      }
      refresh ? _mainFeedPosts = posts : _mainFeedPosts.addAll(posts);
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Post>> getPosts(DateTime startAfter, U user, Feed feed) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeedPosts');
      final res = await callable.call({'startAfter': startAfter.millisecondsSinceEpoch, 'uid': user.uid, 'feedId': feed.id});
      List<Post> posts = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var post in responseData) {
          Post p = Post.fromJson(post);
          p.user = user;
          p.feed = feed;
          posts.add(p);
        }
      }
      return posts;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> subscribeToFeed(String userId, String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('subscribeToFeed');
      final res = await callable.call({'userId': userId, 'feedId': feedId});
      return res.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> unsubscribeFromFeed(String userId, String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('unsubscribeFromFeed');
      final res = await callable.call({'userId': userId, 'feedId': feedId});
      return res.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> requestToJoinFeed(String userId, String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('requestPrivateFeed');
      final res = await callable.call({'userId': userId, 'feedId': feedId});
      return res.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<U>> getFeedRequests(String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeedRequests');
      final res = await callable.call({'feedId': feedId});
      List<U> users = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var user in responseData) {
          users.add(U.fromJson(user));
        }
      }
      return users;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> acceptRequest(String userId, String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('acceptFeedRequest');
      final res = await callable.call({'userId': userId, 'feedId': feedId});
      return res.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> declineRequest(String userId, String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('rejectFeedRequest');
      final res = await callable.call({'userId': userId, 'feedId': feedId});
      return res.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
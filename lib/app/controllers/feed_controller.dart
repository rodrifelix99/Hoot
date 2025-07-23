import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/feed_types.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

import 'package:hoot/models/feed.dart';

class FeedController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  List<Post> _mainFeedPosts = [];
  List<Post> get mainFeedPosts => _mainFeedPosts;

  List<Feed> _topFeeds = [];
  List<Feed> get topFeeds => _topFeeds;

  List<FeedType> _popularTypes = [];
  List<FeedType> get popularTypes => _popularTypes;

  List<Feed> _newFeeds = [];
  List<Feed> get newFeeds => _newFeeds;

  FeedController() {
    _getPrefs();
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _mainFeedPosts = [];
        _topFeeds = [];
        _newFeeds = [];
        update();
      }
    });
  }

  Future _setPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mainFeedPosts',
        jsonEncode(_mainFeedPosts.map((post) => post.toCache()).toList()));
  }

  Future _getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? mainFeedPosts = prefs.getString('mainFeedPosts');
      if (mainFeedPosts != null) {
        List<dynamic> mainFeedPostsJson = jsonDecode(mainFeedPosts);
        _mainFeedPosts =
            mainFeedPostsJson.map((post) => Post.fromCache(post)).toList();
      }
      update();
    } catch (e) {
      logError(e.toString());
      await getMainFeed(DateTime.now(), true);
    }
  }

  Future<bool> createPost(BuildContext context,
      {required String feedId, String? text, List<String>? media}) async {
    try {
      AuthController authController = Get.find<AuthController>();
      Post post = Post(id: '', text: text, media: media, feedId: feedId);
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createPost');
      await callable.call(post.toJson());
      post.user = authController.user;
      post.feed =
          authController.user?.feeds?.firstWhere((f) => f.id == feedId) ??
              Feed(
                  id: feedId,
                  title: 'Posted just now',
                  description: '',
                  icon: '',
                  color: Colors.white,
                  private: false,
                  nsfw: false);
      mainFeedPosts.insert(0, post);
      authController.user?.feeds?.firstWhere((f) => f.id == feedId)
              .posts
              ?.insert(0, post);
      update();
      return true;
    } catch (e) {
      logError(e.toString());
      return false;
    }
  }

  Future<bool> deletePost(
      BuildContext context, String postId, String feedId) async {
    try {
      AuthController authController = Get.find<AuthController>();
      _mainFeedPosts.removeWhere((post) => post.id == postId);
      authController.user?.feeds?.firstWhere((f) => f.id == feedId)
              .posts
              ?.removeWhere((post) => post.id == postId);
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('deletePost');
      await callable.call({'postId': postId, 'feedId': feedId});
      update();
      return true;
    } catch (e) {
      logError(e.toString());
      return false;
    }
  }

  Future<String> createFeed(BuildContext context,
      {required String title,
      required String description,
      required String icon,
      required Color color,
      required FeedType type,
      required bool private,
      required bool nsfw}) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createFeed');
      final res = await callable.call({
        'title': title,
        'description': description,
        'icon': icon,
        'color': color.value.toString(),
        'type': type.toString().split('.').last,
        'private': private,
        'nsfw': nsfw
      });
      Feed feed = Feed(
          id: res.data,
          title: title,
          description: description,
          icon: icon,
          color: color,
          private: private,
          nsfw: nsfw,
          type: type);
      Get.find<AuthController>().addFeedToUser(feed);
      return res.data;
    } catch (e) {
      logError(e.toString());
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
        'type': feed.type.toString().split('.').last,
        'private': feed.private,
        'nsfw': feed.nsfw
      });
      Get.find<AuthController>().removeFeedFromUser(feed.id);
      Get.find<AuthController>().addFeedToUser(feed);
      return res.data;
    } catch (e) {
      if (kDebugMode) {
        logError(e.toString());
      }
      return false;
    }
  }

  Future<bool> deleteFeed(BuildContext context, String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('deleteFeed');
      final res = await callable.call({'feedId': feedId});
      Get.find<AuthController>().removeFeedFromUser(feedId);
      return res.data;
    } catch (e) {
      if (kDebugMode) {
        logError(e.toString());
      }
      return false;
    }
  }

  Future<List<Feed>> getFeeds(String uid) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeeds');
      final res = await callable.call({'uid': uid});
      List<Feed> feeds = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var feed in responseData) {
          feeds.add(Feed.fromJson(feed));
        }
      }
      return feeds;
    } catch (e) {
      if (kDebugMode) {
        logError(e.toString());
      }
      return [];
    }
  }

  Future<void> getMainFeed(DateTime startAfter, bool refresh) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getMainFeedPosts');
      final res = await callable
          .call({'startAfter': startAfter.millisecondsSinceEpoch});
      List<Post> posts = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var post in responseData) {
          posts.add(Post.fromJson(post));
        }
      }
      refresh ? _mainFeedPosts = posts : _mainFeedPosts.addAll(posts);
      update();
      _setPrefs();
    } catch (e) {
      if (kDebugMode) {
        logError(e.toString());
      }
    }
  }

  Future<List<Post>> getPosts(DateTime startAfter, U user, Feed feed) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeedPosts');
      final res = await callable.call({
        'startAfter': startAfter.millisecondsSinceEpoch,
        'uid': user.uid,
        'feedId': feed.id
      });
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
      if (kDebugMode) {
        logError(e.toString());
      }
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
      if (kDebugMode) {
        logError(e.toString());
      }
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
      if (kDebugMode) {
        logError(e.toString());
      }
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
      if (kDebugMode) {
        logError(e.toString());
      }
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
      if (kDebugMode) {
        logError(e.toString());
      }
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
      if (kDebugMode) {
        logError(e.toString());
      }
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
      if (kDebugMode) {
        logError(e.toString());
      }
      return false;
    }
  }

  Future<List<Feed>> getSubscriptions(String uid) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getSubscriptions');
      final res = await callable.call({'uid': uid});
      List<Feed> feeds = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var feed in responseData) {
          feeds.add(Feed.fromJson(feed));
        }
      }
      return feeds;
    } catch (e) {
      logError(e.toString());
      return [];
    }
  }

  Future<List<U>> getSubscribers(String feedId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeedSubscribers');
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
      logError(e.toString());
      return [];
    }
  }

  Future<List<Feed>> top10MostSubscribedFeeds() async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable =
          _functions.httpsCallable('top10MostSubscribedFeeds');
      final res = await callable.call();
      List<Feed> feeds = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var feed in responseData) {
          feeds.add(Feed.fromJson(feed));
        }
      }
      _topFeeds = feeds;
      update();
      return feeds;
    } catch (e) {
      logError(e.toString());
      return [];
    }
  }

  Future<List<FeedType>> getPopularTypes() async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('top5MostPopularTypes');
      final res = await callable.call();
      logError(res.data);
      List<FeedType> types = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var type in responseData) {
          types.add(FeedTypeExtension.fromString(type));
        }
      }
      _popularTypes = types;
      update();
      return types;
    } catch (e) {
      logError(e.toString());
      return [];
    }
  }

  Future<List<Feed>> recentlyAddedFeeds() async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('recentlyAddedFeeds');
      final res = await callable.call();
      List<Feed> feeds = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var feed in responseData) {
          feeds.add(Feed.fromJson(feed));
        }
      }
      _newFeeds = feeds;
      update();
      return feeds;
    } catch (e) {
      logError(e.toString());
      return [];
    }
  }

  Future<List<Feed>> searchFeedsByType(FeedType type, String startAtId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('searchFeedsByType');
      final res = await callable.call(
          {'type': type.toString().split('.').last, 'startAtId': startAtId});
      List<Feed> feeds = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var feed in responseData) {
          feeds.add(Feed.fromJson(feed));
        }
      }
      return feeds;
    } catch (e) {
      logError(e.toString());
      return [];
    }
  }

  Future<bool> likePost(String postId, String feedId, String userId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('likePost');
      final res = await callable
          .call({'postId': postId, 'userId': userId, 'feedId': feedId});
      return res.data;
    } catch (e) {
      logError(e.toString());
      return false;
    }
  }

  Future<bool> refeedPost(String userId, String feedId, String postId,
      String chosenFeedId, String text, List<String> images) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('refeedPost');
      final res = await callable.call({
        'userId': userId,
        'feedId': feedId,
        'postId': postId,
        'chosenFeedId': chosenFeedId,
        'text': text,
        'images': images
      });
      return res.data;
    } catch (e) {
      logError(e.toString());
      return false;
    }
  }

  Future<Post> getPost(String userId, String feedId, String postId) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getPost');
      final res = await callable
          .call({'userId': userId, 'feedId': feedId, 'postId': postId});
      dynamic responseData = jsonDecode(res.data);
      Post p = Post.fromJson(responseData);
      return p;
    } catch (e) {
      logError(e.toString());
      rethrow;
    }
  }

  Future<List<U>> getLikes(
      String userId, String feedId, String postId, DateTime startAfter) async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getLikes');
      final res = await callable.call({
        'userId': userId,
        'feedId': feedId,
        'postId': postId,
        'startAfter': startAfter.millisecondsSinceEpoch
      });
      List<U> users = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var user in responseData) {
          users.add(U.fromJson(user));
        }
      }
      return users;
    } catch (e) {
      logError(e.toString());
      return [];
    }
  }
}

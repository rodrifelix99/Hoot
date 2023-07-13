import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';

class FeedProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  List<Post> _mainFeedPosts = [];
  List<Post> get mainFeedPosts => _mainFeedPosts;

  Future<bool> createPost({required String feedId, String? text, String? media}) async {
    try {
      Post post = Post(
        id: '',
        text: text,
        media: media,
        feedId: feedId
      );
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createPost');
      await callable.call(post.toJson());
      mainFeedPosts.insert(0, post);
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

  Future<bool> deletePost(String postId, String feedId) async {
    try {
      _mainFeedPosts.removeWhere((post) => post.id == postId);
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
}
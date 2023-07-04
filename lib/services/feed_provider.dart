import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoot/models/post.dart';

class FeedProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  List<Post> _feed = [];
  List<Post> get feed => _feed;

  Future<bool> createPost({String? text, String? media}) async {
    try {
      Post post = Post(
        id: '',
        text: text,
        media: media
      );
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createPost');
      await callable.call(post.toJson());
      feed.insert(0, post);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> getFeed() async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeed');
      final res = await callable.call();
      List<Post> posts = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var post in responseData) {
          posts.add(Post.fromJson(post));
        }
      }
      _feed = posts;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}

/* class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  final List<Post> _feed = [];
  get feed => _feed;

  Future<bool> createPost({String? text, String? media}) async {
    try {
      Post post = Post(
        id: '',
        text: text,
        media: media
      );
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('createPost');
      await callable.call(post.toJson());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future getFeed() async {
    try {
      await _auth.currentUser!.getIdToken(true);
      HttpsCallable callable = _functions.httpsCallable('getFeed');
      final res = await callable.call();
      List<Post> posts = [];
      if (res.data != null) {
        dynamic responseData = jsonDecode(res.data);
        for (var post in responseData) {
          posts.add(Post.fromJson(post));
        }
      }
      _feed.addAll(posts);
    } catch (e) {
      print("Error getting feed: $e");
      rethrow;
    }
  }

}*/
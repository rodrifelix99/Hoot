import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/post_service.dart';

import '../data/mock_user.dart';

/// Mock implementation of [BasePostService] storing posts in memory.
class MockPostService implements BasePostService {
  final List<Post> _posts = [];

  /// Loads posts from bundled JSON sample data.
  Future<void> load() async {
    final raw = await rootBundle.loadString('mock/data/sample_posts.json');
    final data = jsonDecode(raw) as List<dynamic>;
    _posts.addAll(data.map((e) => Post.fromJson(e as Map<String, dynamic>)));
  }

  List<Post> get posts => _posts;

  @override
  String newPostId() => (_posts.length + 1).toString();

  @override
  Future<void> createPost(Map<String, dynamic> data, {String? id}) async {
    final post = Post.fromJson({
      'id': id ?? newPostId(),
      ...data,
      'user': mockUser.toJson(),
    });
    _posts.insert(0, post);
  }

  @override
  Future<void> toggleLike(String postId, String userId, bool like) async {
    final post =
        _posts.firstWhere((p) => p.id == postId, orElse: () => Post.empty());
    if (post.id == '0') return;
    post.liked = like;
    post.likes = (post.likes ?? 0) + (like ? 1 : -1);
  }

  @override
  Future<Post?> fetchPost(String id) async {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> reFeed(
      {required Post original,
      required Feed targetFeed,
      required U user}) async {
    final newId = newPostId();
    final clone = Post(
      id: newId,
      text: original.text,
      feedId: targetFeed.id,
      feed: targetFeed,
      user: user,
      reFeeded: true,
      reFeededFrom: original,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, clone);
    return newId;
  }

  @override
  Future<void> deletePost(String id) async {
    _posts.removeWhere((p) => p.id == id);
  }
}

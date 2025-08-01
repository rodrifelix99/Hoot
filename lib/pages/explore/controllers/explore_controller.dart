import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/util/enums/feed_types.dart';

/// Controller in charge of fetching data for the explore page.
class ExploreController extends GetxController {
  final FirebaseFirestore _firestore;

  ExploreController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Text editing controller used by the search field.
  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;

  /// Search results for users and feeds.
  final RxList<U> userSuggestions = <U>[].obs;
  final RxList<Feed> feedSuggestions = <Feed>[].obs;
  final RxBool searching = false.obs;

  /// Top feeds ordered by subscriber count.
  final RxList<Feed> topFeeds = <Feed>[].obs;

  /// Users with the highest popularity score.
  final RxList<U> popularUsers = <U>[].obs;

  /// Recently created feeds.
  final RxList<Feed> newFeeds = <Feed>[].obs;

  /// Most popular recent posts from public feeds.
  final RxList<Post> topPosts = <Post>[].obs;

  /// Popular feed genres.
  final RxList<FeedType> genres = <FeedType>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadExploreData();
  }

  /// Reloads explore data and search suggestions.
  Future<void> refreshExplore() async {
    await _loadExploreData();
    if (query.value.isNotEmpty) {
      await search(query.value);
    }
  }

  /// Loads initial explore data.
  Future<void> _loadExploreData() async {
    await Future.wait([
      loadTopFeeds(),
      loadPopularUsers(),
      loadNewFeeds(),
      loadGenres(),
      loadTopPosts(),
    ]);
  }

  /// Queries the ten feeds with most subscribers.
  Future<void> loadTopFeeds() async {
    final snapshot = await _firestore
        .collection('feeds')
        .orderBy('subscriberCount', descending: true)
        .limit(10)
        .get();
    topFeeds.assignAll(snapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList());
  }

  /// Queries the ten newest feeds.
  Future<void> loadNewFeeds() async {
    final snapshot = await _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    newFeeds.assignAll(snapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList());
  }

  /// Queries the ten users with highest popularity score.
  Future<void> loadPopularUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('popularityScore', descending: true)
        .limit(10)
        .get();
    popularUsers
        .assignAll(snapshot.docs.map((d) => U.fromJson(d.data())).toList());
  }

  /// Queries the most popular recent posts from public feeds.
  Future<void> loadTopPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .where('feed.private', isEqualTo: false)
        .orderBy('likes', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    topPosts.assignAll(snapshot.docs
        .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
        .toList());
  }

  /// Retrieves the most common feed genres from the most popular feeds.
  Future<void> loadGenres() async {
    final snapshot = await _firestore
        .collection('feeds')
        .orderBy('subscriberCount', descending: true)
        .limit(20)
        .get();

    final types = snapshot.docs
        .map((d) => d.data()['type'] as String?)
        .whereType<String>()
        .map(FeedTypeExtension.fromString)
        .toList();

    // Keep unique types while preserving order.
    final seen = <FeedType>{};
    final uniqueTypes = <FeedType>[];
    for (final t in types) {
      if (seen.add(t)) uniqueTypes.add(t);
      if (uniqueTypes.length == 10) break;
    }

    genres.assignAll(uniqueTypes);
  }

  /// Searches for users and feeds matching [query].
  Future<void> search(String value) async {
    query.value = value;
    if (value.isEmpty) {
      userSuggestions.clear();
      feedSuggestions.clear();
      return;
    }

    searching.value = true;
    try {
      final futures = await Future.wait([
        _firestore
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: value)
            .where('username', isLessThanOrEqualTo: '$value\uf8ff')
            .limit(5)
            .get(),
        _firestore
            .collection('feeds')
            .where('title', isGreaterThanOrEqualTo: value)
            .where('title', isLessThanOrEqualTo: '$value\uf8ff')
            .limit(5)
            .get(),
      ]);

      final userSnap = futures[0];
      final feedSnap = futures[1];

      userSuggestions.assignAll(
        userSnap.docs.map((d) => U.fromJson(d.data())).toList(),
      );
      feedSuggestions.assignAll(feedSnap.docs
          .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
          .toList());
    } finally {
      searching.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

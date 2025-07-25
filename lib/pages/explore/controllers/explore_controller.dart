import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/feed.dart';
import '../../../models/user.dart';
import '../../../util/enums/feed_types.dart';

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

  /// Recently created feeds.
  final RxList<Feed> newFeeds = <Feed>[].obs;

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
      loadNewFeeds(),
      loadGenres(),
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

  /// Retrieves the most popular feed genres from Firestore.
  Future<void> loadGenres() async {
    final snapshot = await _firestore
        .collection('feed_types')
        .orderBy('count', descending: true)
        .limit(10)
        .get();
    genres.assignAll(snapshot.docs
        .map((d) => FeedTypeExtension.fromString(d.id))
        .toList());
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


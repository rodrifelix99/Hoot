import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../models/feed.dart';
import '../../../util/enums/feed_types.dart';

/// Controller that loads feeds for a specific [FeedType].
class SearchByGenreController extends GetxController {
  final FirebaseFirestore _firestore;

  SearchByGenreController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  late FeedType type;
  final RxList<Feed> feeds = <Feed>[].obs;

  @override
  void onInit() {
    super.onInit();
    type = Get.arguments as FeedType;
    loadFeeds();
  }

  /// Loads feeds of the selected [type].
  Future<void> loadFeeds() async {
    final snapshot = await _firestore
        .collection('feeds')
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('subscriberCount', descending: true)
        .limit(20)
        .get();
    feeds.assignAll(snapshot.docs
        .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
        .toList());
  }
}


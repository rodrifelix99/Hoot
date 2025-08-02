import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/util/enums/feed_types.dart';

/// Controller that loads feeds for a specific [FeedType].
class SearchByGenreController extends GetxController {
  final FirebaseFirestore _firestore;

  SearchByGenreController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  late FeedType type;

  final Rx<PagingState<DocumentSnapshot?, Feed>> state =
      PagingState<DocumentSnapshot?, Feed>().obs;

  @override
  void onInit() {
    super.onInit();
    type = Get.arguments as FeedType;
    fetchNextPage();
  }

  /// Loads a new page of feeds of the selected [type].
  void fetchNextPage() async {
    final current = state.value;
    if (current.isLoading) return;

    state.value = current.copyWith(isLoading: true, error: null);

    try {
      const limit = 20;
      Query<Map<String, dynamic>> query = _firestore
          .collection('feeds')
          .where('type', isEqualTo: type.toString().split('.').last)
          .orderBy('subscriberCount', descending: true)
          .limit(limit);

      final lastDoc = current.keys?.last;
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      final feeds = snapshot.docs
          .map((d) => Feed.fromJson({'id': d.id, ...d.data()}))
          .toList();

      state.value = state.value.copyWith(
        pages: [...?current.pages, feeds],
        keys: [
          ...?current.keys,
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null
        ],
        hasNextPage: snapshot.docs.length == limit,
        isLoading: false,
      );
    } catch (e) {
      state.value = state.value.copyWith(error: e, isLoading: false);
    }
  }

  @override
  void refresh() {
    state.value = state.value.reset();
    fetchNextPage();
  }
}

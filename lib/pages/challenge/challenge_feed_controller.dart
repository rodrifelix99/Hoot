import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hoot/models/daily_challenge.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/challenge_service.dart';
import 'package:hoot/util/constants.dart';
import 'package:hoot/util/enums/feed_types.dart';

/// Controller for filtering challenge feed posts based on NSFW settings.
class ChallengeFeedController extends GetxController {
  final AuthService _authService;
  final BaseChallengeService _challengeService;
  final FirebaseFirestore _firestore;

  ChallengeFeedController({
    AuthService? authService,
    BaseChallengeService? challengeService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _challengeService =
            challengeService ?? Get.find<BaseChallengeService>(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final Rxn<DailyChallenge> challenge = Rxn<DailyChallenge>();
  final RxBool challengeLoading = true.obs;
  final RxList<Post> posts = <Post>[].obs;
  final RxBool postsLoading = false.obs;
  final Rxn<Object> postsError = Rxn<Object>();
  final RxBool hasAnyPosts = false.obs;

  late final StreamSubscription<DailyChallenge?> _challengeSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _postsSub;

  @override
  void onInit() {
    super.onInit();
    _challengeSub = _challengeService.watchCurrentChallenge().listen((c) {
      challenge.value = c;
      challengeLoading.value = false;
      if (c == null) {
        posts.clear();
        postsLoading.value = false;
        postsError.value = null;
        hasAnyPosts.value = false;
        _postsSub?.cancel();
        _postsSub = null;
      } else {
        _subscribeToPosts(c.id);
      }
    });
  }

  bool get noActiveChallenge =>
      !challengeLoading.value && challenge.value == null;

  void _subscribeToPosts(String challengeId) {
    postsLoading.value = true;
    postsError.value = null;
    hasAnyPosts.value = false;
    _postsSub?.cancel();
    _postsSub = _firestore
        .collection('posts')
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final fetched = snapshot.docs
          .map((d) => Post.fromJson({'id': d.id, ...d.data()}))
          .toList();
      hasAnyPosts.value = fetched.isNotEmpty;
      posts.value = filterPosts(fetched);
      postsLoading.value = false;
    }, onError: (e, st) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(
          e,
          st,
          reason: 'Failed to load challenge posts',
        );
      }
      postsError.value = e;
      postsLoading.value = false;
    });
  }

  bool get _shouldHideAdultContent {
    final user = _authService.currentUser;
    final created = user?.createdAt;
    if (created == null) return false;
    return DateTime.now().difference(created) <
        const Duration(days: kAdultContentAccountAgeDays);
  }

  /// Filters out adult or NSFW posts when the user filter is active.
  List<Post> filterPosts(List<Post> posts) {
    if (!_shouldHideAdultContent) return posts;
    return posts
        .where((p) =>
            p.feed?.type != FeedType.adultContent &&
            (p.feed?.nsfw ?? false) != true &&
            (p.nsfw ?? false) != true)
        .toList();
  }

  @override
  void onClose() {
    _challengeSub.cancel();
    _postsSub?.cancel();
    super.onClose();
  }
}

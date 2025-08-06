import 'package:get/get.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/constants.dart';
import 'package:hoot/util/enums/feed_types.dart';

/// Controller for filtering challenge feed posts based on NSFW settings.
class ChallengeFeedController extends GetxController {
  final AuthService _authService;

  ChallengeFeedController({AuthService? authService})
      : _authService = authService ?? Get.find<AuthService>();

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
}

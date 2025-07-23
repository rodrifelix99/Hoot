import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import '../app/utils/logger.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/error_service.dart';

class PostPage extends StatefulWidget {
  final Post? post;
  final String? postId;
  final String? feedId;
  final String? userId;
  const PostPage({super.key, this.post, this.postId, this.feedId, this.userId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  FeedController _feedProvider = FeedController();
  bool _loading = false;
  bool _loadingLikes = false;
  Post? _post;
  
  Post? get post => widget.post ?? _post;

  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    super.initState();
    widget.post == null ? _getPost() : _getLikes(DateTime.now());
  }

  Future _getPost() async {
    setState(() => _loading = true);
    _post = await _feedProvider.getPost(
        widget.userId!, widget.feedId!, widget.postId!);
    setState(() => _loading = false);
    await _getLikes(DateTime.now());
  }

  Future _getLikes(DateTime startAfter, {bool refresh = false}) async {
    try {
      if (post!.likers.isEmpty && !refresh) {
        setState(() => _loadingLikes = true);
      }
      List<U> likes = await _feedProvider.getLikes(post!.user!.uid,
          post!.feed!.id, post!.id, startAfter);
      setState(() => post!.likers = likes);
    } catch (e) {
      logError(e.toString());
      ToastService.showToast(context, "Error getting likes", true);
    } finally {
      setState(() => _loadingLikes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'appName'.tr,
      ),
      body: post == null && !_loading
          ? Center(
              child: NothingToShowComponent(
                  icon: const Icon(SolarIconsBold.eraserSquare),
                  text: 'hootDeletedOrDoesntExist'.tr))
          : SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _loading
                    ? PostComponent(
                        post: Post.empty(),
                        isSkeleton: true,
                      )
                    : PostComponent(
                        post: post!,
                        onDeleted: () => Get.back(),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('likes'.tr,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 5),
                      Text(
                        'likes10RecentLabel'.tr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _loadingLikes
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ShimmerListTile(
                              leadingSize: 50,
                              hasSubtitle: false,
                            ),
                            ShimmerListTile(
                              leadingSize: 50,
                              hasSubtitle: false,
                            ),
                            ShimmerListTile(
                              leadingSize: 50,
                              hasSubtitle: false,
                            ),
                            ShimmerListTile(
                              leadingSize: 50,
                              hasSubtitle: false,
                            ),
                          ],
                        ),
                      )
                    : (post?.likers.isEmpty ?? true)
                        ? const Center(
                            child: NothingToShowComponent(
                            icon: Icon(SolarIconsBold.heartAngle),
                            text: 'No likes yet',
                          ))
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: post!.likers.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () => Get.toNamed('/profile',
                                    arguments: post!.likers[index]),
                                leading: ProfileAvatarComponent(
                                    image: post!.likers[index]
                                            .smallProfilePictureUrl ??
                                        '',
                                    size: 50),
                                title:
                                    Text(post!.likers[index].name ?? ''),
                                subtitle: Text(
                                    "@${post!.likers[index].username}"),
                              );
                            },
                          )
              ],
            )),
    );
  }
}

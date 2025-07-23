import 'package:hoot/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import '../app/utils/logger.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:hoot/models/post.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/error_service.dart';

class PostPage extends StatefulWidget {
  Post? post;
  final String? postId;
  final String? feedId;
  final String? userId;
  PostPage({super.key, this.post, this.postId, this.feedId, this.userId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  FeedController _feedProvider = FeedController();
  bool _loading = false;
  bool _loadingLikes = false;

  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    super.initState();
    widget.post == null ? _getPost() : _getLikes(DateTime.now());
  }

  Future _getPost() async {
    setState(() => _loading = true);
    widget.post = await _feedProvider.getPost(
        widget.userId!, widget.feedId!, widget.postId!);
    setState(() => _loading = false);
    await _getLikes(DateTime.now());
  }

  Future _getLikes(DateTime startAfter, {bool refresh = false}) async {
    try {
      if (widget.post!.likers.isEmpty && !refresh) {
        setState(() => _loadingLikes = true);
      }
      List<U> likes = await _feedProvider.getLikes(widget.post!.user!.uid,
          widget.post!.feed!.id, widget.post!.id, startAfter);
      setState(() => widget.post!.likers = likes);
    } catch (e) {
      logError(e);
      ToastService.showToast(context, "Error getting likes", true);
    } finally {
      setState(() => _loadingLikes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: AppLocalizations.of(context)!.appName,
      ),
      body: widget.post == null && !_loading
          ? Center(
              child: NothingToShowComponent(
                  icon: const Icon(SolarIconsBold.eraserSquare),
                  text: AppLocalizations.of(context)!.hootDeletedOrDoesntExist))
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
                        post: widget.post!,
                        onDeleted: () => Get.back(),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.likes,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.likes10RecentLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.5),
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
                            SkeletonListTile(
                              leadingStyle: const SkeletonAvatarStyle(
                                shape: BoxShape.circle,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SkeletonListTile(
                              leadingStyle: const SkeletonAvatarStyle(
                                shape: BoxShape.circle,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SkeletonListTile(
                              leadingStyle: const SkeletonAvatarStyle(
                                shape: BoxShape.circle,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SkeletonListTile(
                              leadingStyle: const SkeletonAvatarStyle(
                                shape: BoxShape.circle,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                      )
                    : (widget.post?.likers.isEmpty ?? true)
                        ? const Center(
                            child: NothingToShowComponent(
                            icon: Icon(SolarIconsBold.heartAngle),
                            text: 'No likes yet',
                          ))
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.post!.likers.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () => Get.toNamed(context, '/profile',
                                    arguments: widget.post!.likers[index]),
                                leading: ProfileAvatarComponent(
                                    image: widget.post!.likers[index]
                                            .smallProfilePictureUrl ??
                                        '',
                                    size: 50),
                                title:
                                    Text(widget.post!.likers[index].name ?? ''),
                                subtitle: Text(
                                    "@${widget.post!.likers[index].username}"),
                              );
                            },
                          )
              ],
            )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/components/like_button_component.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/services/post_service.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/dialog_service.dart';
import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/report_service.dart';
import 'package:hoot/util/mention_utils.dart';
import 'package:hoot/util/extensions/datetime_extension.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:hoot/util/routes/args/profile_args.dart';

class PostComponent extends StatefulWidget {
  final Post post;
  final BasePostService? postService;
  final BaseReportService? reportService;
  final EdgeInsetsGeometry? margin;

  const PostComponent({
    required this.post,
    this.postService,
    this.reportService,
    this.margin,
    super.key,
  });

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  late Post _post;
  late BasePostService _postService;
  late AuthService _authService;
  late BaseReportService _reportService;

  @override
  void initState() {
    _post = widget.post;
    _postService = widget.postService ??
        (Get.isRegistered<BasePostService>()
            ? Get.find<BasePostService>()
            : PostService());
    _authService = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : AuthService();
    _reportService = widget.reportService ??
        (Get.isRegistered<BaseReportService>()
            ? Get.find<BaseReportService>()
            : ReportService());
    super.initState();

    if (_post.reFeeded &&
        _post.reFeededFrom?.id != null &&
        _post.reFeededFrom?.user == null) {
      _postService.fetchPost(_post.reFeededFrom!.id).then((orig) {
        if (orig != null) {
          setState(() {
            _post.reFeededFrom = orig;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant PostComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post != oldWidget.post) {
      setState(() {
        _post = widget.post;
      });
    }
  }

  Future<void> _toggleLike() async {
    final user = _authService.currentUser;
    if (user == null) return;
    final newLiked = !_post.liked;
    setState(() {
      _post
        ..liked = newLiked
        ..likes = (_post.likes ?? 0) + (newLiked ? 1 : -1);
    });
    try {
      await _postService.toggleLike(_post.id, user.uid, newLiked);
    } catch (_) {
      setState(() {
        _post
          ..liked = !newLiked
          ..likes = (_post.likes ?? 0) + (newLiked ? -1 : 1);
      });
    }
  }

  Future<void> _reFeed() async {
    final user = _authService.currentUser;
    if (user == null) return;
    if (_post.reFeededByMe) return;
    final feeds = user.feeds ?? [];
    if (feeds.isEmpty) {
      ToastService.showError('youNeedToCreateAFeedFirst'.tr);
      return;
    }
    final feed = await DialogService.showActionSheet<Feed>(
      context: context,
      title: 'selectAFeedToRefeedTo'.tr,
      actions: [
        for (final f in feeds) SheetAction<Feed>(label: f.title, key: f),
      ],
    );
    if (feed == null) return;
    await _postService.reFeed(original: _post, targetFeed: feed, user: user);
    setState(() {
      _post.reFeeds = (_post.reFeeds ?? 0) + 1;
      _post.reFeededByMe = true;
    });
    ToastService.showSuccess('newReHoot'.tr);
  }

  Future<void> _showOptions() async {
    final user = _authService.currentUser;
    final isOwner = user != null && user.uid == _post.user?.uid;
    final action = await DialogService.showActionSheet<String>(
      context: context,
      actions: [
        if (isOwner)
          SheetAction(
              label: 'deletePost'.tr, key: 'delete', isDestructiveAction: true)
        else
          SheetAction(label: 'reportPost'.tr, key: 'report'),
      ],
    );
    if (action == 'delete') {
      final confirmed = await DialogService.confirm(
        context: context,
        title: 'deletePost'.tr,
        message: 'deletePostConfirmation'.tr,
        okLabel: 'delete'.tr,
        cancelLabel: 'cancel'.tr,
      );
      if (!confirmed) return;
      try {
        await _postService.deletePost(_post.id);
        ToastService.showSuccess('deletePost'.tr);
      } catch (e) {
        ToastService.showError('somethingWentWrong'.tr);
      }
    } else if (action == 'report') {
      final reasons = await showTextInputDialog(
        context: context,
        title: 'reportPost'.tr,
        textFields: [
          DialogTextField(
            hintText: 'reportPostInfo'.tr,
            minLines: 3,
            maxLength: 500,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      );
      final reason = reasons?.first;
      if (reason == null || reason.isEmpty) return;
      try {
        await _reportService.reportPost(postId: _post.id, reason: reason);
        ToastService.showSuccess('reportSent'.tr);
      } catch (e) {
        ToastService.showError('somethingWentWrong'.tr);
      }
    }
  }

  void _openPostDetails() {
    Get.toNamed(AppRoutes.post, arguments: _post);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(75),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticService.lightImpact();
          _openPostDetails();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            if (_post.reFeeded)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainer
                      .withAlpha(100),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withAlpha(25),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(SolarIconsOutline.refreshSquare, size: 16),
                    const SizedBox(width: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(text: '${'reHootOf'.tr} '),
                          if (_post.reFeededFrom?.user != null)
                            TextSpan(
                              text:
                                  '@${_post.reFeededFrom!.user!.username ?? ''}',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (_post.reFeededFrom?.id != null) {
                                    Get.toNamed(AppRoutes.post, arguments: {
                                      'id': _post.reFeededFrom!.id
                                    });
                                  }
                                },
                            )
                          else
                            const TextSpan(text: '@...'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(
                bottom: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticService.lightImpact();
                          if (_post.feed != null) {
                            Get.toNamed(
                              AppRoutes.feed,
                              arguments: FeedPageArgs(feed: _post.feed),
                            );
                          }
                        },
                        child: ProfileAvatarComponent(
                          image: _post.smallAvatar,
                          hash: _post.smallAvatarHash,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_post.user != null)
                        GestureDetector(
                          onTap: () {
                            HapticService.lightImpact();
                            Get.toNamed(
                              AppRoutes.profile,
                              arguments: ProfileArgs(uid: _post.user!.uid),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.4,
                                ),
                                child: Text(
                                  _post.feed?.title ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'by @${_post.user?.username ?? ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  if (_post.user?.verified == true) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      if (_post.createdAt != null)
                        Text(
                          _post.createdAt!.timeAgo(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: _showOptions,
                      ),
                    ],
                  ),
                  if (_post.text != null && _post.text!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineSmall,
                        children: parseMentions(_post.text!),
                      ),
                    ),
                  ],
                  if (_post.url != null) ...[
                    const SizedBox(height: 16),
                    UrlPreviewComponent(url: _post.url!),
                  ],
                  if (_post.media != null && _post.media!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    if (_post.media!.length == 1)
                      AspectRatio(
                        aspectRatio: 1,
                        child: ImageComponent(
                          url: _post.media!.first,
                          hash: _post.hashes != null && _post.hashes!.isNotEmpty
                              ? _post.hashes!.first
                              : null,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          radius: 16,
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: Get.width - 32,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            childAspectRatio: 1,
                          ),
                          itemCount: _post.media!.length,
                          itemBuilder: (context, i) {
                            return ImageComponent(
                              url: _post.media![i],
                              hash: _post.hashes != null &&
                                      i < _post.hashes!.length
                                  ? _post.hashes![i]
                                  : null,
                              fit: BoxFit.cover,
                              radius: 8,
                            );
                          },
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      LikeButtonComponent(
                        liked: _post.liked,
                        onTap: _toggleLike,
                      ),
                      if ((_post.likes ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('${_post.likes ?? 0}'),
                        ),
                      const Spacer(
                        flex: 2,
                      ),
                      Builder(
                        builder: (context) {
                          final bool isPrivateFeed = _post.reFeeded
                              ? _post.reFeededFrom?.feed?.private ?? false
                              : _post.feed?.private ?? false;
                          return Opacity(
                            opacity: isPrivateFeed ? 0.5 : 1,
                            child: IconButton(
                              icon: Icon(
                                SolarIconsOutline.refreshSquare,
                                color: _post.reFeededByMe ? Colors.green : null,
                              ),
                              iconSize: 20,
                              onPressed: (_post.reFeededByMe || isPrivateFeed)
                                  ? null
                                  : _reFeed,
                            ),
                          );
                        },
                      ),
                      if ((_post.reFeeds ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('${_post.reFeeds ?? 0}'),
                        ),
                      const Spacer(
                        flex: 2,
                      ),
                      IconButton(
                        icon: const Icon(SolarIconsOutline.chatRoundLine),
                        iconSize: 20,
                        onPressed: _openPostDetails,
                      ),
                      Text('${_post.comments ?? 0}'),
                      const SizedBox(width: 8),
                      const Spacer(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

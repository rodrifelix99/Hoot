import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/services/error_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:hoot/components/shimmer_skeletons.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hoot/models/feed.dart';
import 'package:hoot/app/controllers/feed_controller.dart';

class PostComponent extends StatefulWidget {
  final Post post;
  final bool showToolbar;
  final bool showTitleBar;
  final VoidFutureCallBack? onRefeed;
  final bool isSkeleton;
  final Function? onDeleted;
  const PostComponent({super.key, required this.post, this.showToolbar = true, this.showTitleBar = true, this.onRefeed, this.isSkeleton = false, this.onDeleted});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> with TickerProviderStateMixin {
  late AuthController _authProvider;
  late FeedController _feedProvider;
  bool _deleted = false;

  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    _feedProvider = Get.find<FeedController>();
    super.initState();
  }

  void _handleProfileTap() {
    Navigator.of(context).pushNamed('/profile', arguments: [widget.post.user, widget.post.feed?.id]);
  }

  String? _getUrl() {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(widget.post.text ?? '');
    if (matches.isNotEmpty) {
      String url = matches.first.group(0)!; // Extract the matched URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'http://$url'; // Add http:// prefix if not present
      }
      return url;
    } else {
      return null;
    }
  }

  String _getText() {
    return widget.post.text?.replaceAll(_getUrl() ?? '', '').trim() ?? '';
  }

  Future<void> _deletePost() async {
    if (widget.post.user?.uid != _authProvider.user?.uid) return;
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this hoot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              setState(() => _deleted = true);
              bool res = await _feedProvider.deletePost(context, widget.post.id, widget.post.feed!.id);
              if (!res) {
                ToastService.showToast(context, 'Error deleting post', true);
              } else if (widget.onDeleted != null) {
                widget.onDeleted!();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return widget.post.user?.uid == _authProvider.user?.uid ? ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          leading: const Icon(Icons.delete),
          title: Text('delete'.tr),
          onTap: () {
            Navigator.of(context).pop();
            _deletePost();
          },
        ) : ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            leading: const Icon(Icons.report),
            title: Text('reportUsername'.trParams({'value': widget.post.user?.username ?? ''})),
            onTap: () {
              Navigator.of(context).pop();
              ToastService.showToast(context, 'Reported', false);
            }
        );
      },
    );
  }

  Future refeed() async {
    if(widget.post.reFeeded && widget.onRefeed != null) {
      await widget.onRefeed!();
      return;
    } else if (_authProvider.user?.feeds == null || _authProvider.user!.feeds!.isEmpty) {
      ToastService.showToast(context, 'Wait a second', false);
      List<Feed> feeds = await _feedProvider.getFeeds(_authProvider.user!.uid);
      setState(() {
        _authProvider.user!.feeds = feeds;
      });
    } else if (widget.post.reFeeded) {
      ToastService.showToast(context, 'deleteOnRefeededPost'.tr, false);
      return;
    }

    if (_authProvider.user?.feeds == null || _authProvider.user!.feeds!.isEmpty) {
      ToastService.showToast(context, 'youNeedToCreateAFeedFirst'.tr, false);
      return;
    }

    //dialog asking for feed with a dropdown
    String? feedId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refeed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('selectAFeedToRefeedTo'.tr),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Feed',
              ),
              value: _authProvider.user?.feeds?.first.id,
              onChanged: (value) => Navigator.of(context).pop(value),
              items: _authProvider.user?.feeds?.map((feed) => DropdownMenuItem<String>(
                value: feed.id,
                child: Text(feed.title),
              )).toList() ?? [],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop( _authProvider.user?.feeds?.first.id),
            child: const Text('ReFeed'),
          ),
        ],
      ),
    );
    if(feedId == null) return;

    setState(() {
      widget.post.reFeeded = true;
      widget.post.reFeeds = (widget.post.reFeeds ?? 0) + 1;
    });
    bool res = await _feedProvider.refeedPost(widget.post.user!.uid, widget.post.feed!.id, widget.post.id, feedId, '', []);
    if (!res) {
      setState(() {
        widget.post.reFeeded = false;
        widget.post.reFeeds = (widget.post.reFeeds ?? 0) - 1 < 0 ? 0 : (widget.post.reFeeds ?? 0) - 1;
      });
      ToastService.showToast(context, 'Error refeeding post', true);
    }
  }

  Future toggleLike() async {
    if (widget.post.liked) {
      setState(() {
        widget.post.liked = false;
        widget.post.likes = (widget.post.likes ?? 0) - 1 < 0 ? 0 : (widget.post.likes ?? 0) - 1;
      });
      bool res = await _feedProvider.likePost(widget.post.id, widget.post.feed!.id, widget.post.user!.uid);
      if (!res) {
        setState(() {
          widget.post.liked = true;
          widget.post.likes = (widget.post.likes ?? 0) + 1;
        });
        ToastService.showToast(context, 'Error disliking post', true);
      }
    } else {
      // Like the post
      setState(() {
        widget.post.liked = true;
        widget.post.likes = (widget.post.likes ?? 0) + 1;
      });
      bool res = await _feedProvider.likePost(widget.post.id, widget.post.feed!.id, widget.post.user!.uid);
      if (!res) {
        setState(() {
          widget.post.liked = false;
          widget.post.likes = (widget.post.likes ?? 0) - 1 < 0 ? 0 : (widget.post.likes ?? 0) - 1;
        });
        ToastService.showToast(context, 'Error liking post', true);
      }
    }
  }

  bool _canRefeed() => widget.post.user!.uid != _authProvider.user!.uid && widget.post.reFeededFrom == null;

  @override
  Widget build(BuildContext context) {
    return _deleted ? const SizedBox() : widget.isSkeleton ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(
                width: 40,
                height: 40,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: 20,
                  ),
                  const SizedBox(height: 5),
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.10,
                    height: 20,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          const ShimmerParagraph(lines: 2, spacing: 10),
        ],
      ),
    ) :
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.showTitleBar ? TitleBar(
            post: widget.post,
            onProfileTap: _handleProfileTap,
          ) : const SizedBox(),
          if (widget.post.text?.isNotEmpty ?? false) ...[
            Text(
              _getText(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 20,
              ),
            ),
          ],
          if (_getUrl() != null) ...[
            const SizedBox(height: 10),
            UrlPreviewComponent(
              url: _getUrl()!,
            ),
          ],
          if (widget.post.media?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            MediaSection(
              post: widget.post,
            ),
          ],
          if (widget.post.reFeededFrom != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                '/post',
                arguments: widget.post.reFeededFrom,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    PostComponent(
                        post: widget.post.reFeededFrom!,
                        showToolbar: false,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
          if (widget.showToolbar) ...[
            const SizedBox(height: 10),
            ToolBar(
              post: widget.post,
              onMenuTap: _handleMenuTap,
              onLikeTap: toggleLike,
              onRefeedTap: refeed,
              canRefeed: _canRefeed(),
            ),
          ]
        ],
      ),
    );
  }
}

class TitleBar extends StatelessWidget {
  final Post post;
  final Function onProfileTap;
  const TitleBar({super.key, required this.post, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onProfileTap(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: post.feed?.color?.withValues(alpha: 0.25) ?? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(-4, 2),
                  ),
                ]
              ),
              child: ProfileAvatarComponent(
                image: post.user!.smallProfilePictureUrl ?? '',
                size: 50,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onProfileTap(),
                child: Text(
                  post.user!.name ?? post.user!.username!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                post.feed?.title ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            timeago.format(post.createdAt ?? DateTime.now()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaSection extends StatelessWidget {
  final Post post;
  const MediaSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return (post.media?.isNotEmpty ?? false) ? SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width - 40,
      child: Swiper(
        containerHeight: 300,
        containerWidth: MediaQuery.of(context).size.width - 40,
        itemCount: post.media!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ImageComponent(
                url: post.media![index],
                radius: 10,
              ),
            ),
          );
        },
        pagination: post.media!.length <= 1 ? null : SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            space: 5,
            activeSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            activeColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ) : const SizedBox.shrink();
  }
}

class ToolBar extends StatelessWidget {
  final Post post;
  final Function onMenuTap;
  final Function onLikeTap;
  final Function onRefeedTap;
  final bool canRefeed;
  const ToolBar({super.key, required this.post, required this.onMenuTap, required this.onLikeTap, required this.onRefeedTap, required this.canRefeed});

  @override
  Widget build(BuildContext context) {
    Color color = post.feed?.color ?? Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => onLikeTap(),
                  icon: Icon(
                    post.liked ? SolarIconsBold.heart : SolarIconsOutline.heart,
                    color: post.liked ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${post.likes ?? 0}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            canRefeed ? Row(
              children: [
                IconButton(
                  onPressed: canRefeed ? () => onRefeedTap() : null,
                  icon: Icon(
                    post.reFeeded ? SolarIconsBold.refreshSquare : SolarIconsOutline.refreshSquare,
                    color: post.reFeeded ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${post.reFeeds ?? 0}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ) : const SizedBox.shrink(),
            IconButton(
              onPressed: () => onMenuTap(),
              icon: Icon(
                SolarIconsOutline.menuDots,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          thickness: 1,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}



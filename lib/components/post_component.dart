import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/feed.dart';
import '../services/feed_provider.dart';

class PostComponent extends StatefulWidget {
  final Post post;
  final bool showToolbar;
  final bool showTitleBar;
  final VoidFutureCallBack? onRefeed;
  final bool isSkeleton;
  const PostComponent({super.key, required this.post, this.showToolbar = true, this.showTitleBar = true, this.onRefeed, this.isSkeleton = false});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> with TickerProviderStateMixin {
  late AuthProvider _authProvider;
  late FeedProvider _feedProvider;
  bool _deleted = false;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
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

  Future<void> _deletePost() async {
    if (widget.post.user?.uid != _authProvider.user?.uid) return;
    // confirmation dialog
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
          title: Text(AppLocalizations.of(context)!.delete),
          onTap: () {
            Navigator.of(context).pop();
            _deletePost();
          },
        ) : ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            leading: const Icon(Icons.report),
            title: Text(AppLocalizations.of(context)!.reportUsername(widget.post.user?.username ?? '')),
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
      ToastService.showToast(context, AppLocalizations.of(context)!.deleteOnRefeededPost, false);
      return;
    }

    if (_authProvider.user?.feeds == null || _authProvider.user!.feeds!.isEmpty) {
      ToastService.showToast(context, AppLocalizations.of(context)!.youNeedToCreateAFeedFirst, false);
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
            Text(AppLocalizations.of(context)!.selectAFeedToRefeedTo),
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
            child: Text(AppLocalizations.of(context)!.cancel),
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

  bool _isEmptyRefeed() => widget.post.reFeededFrom != null && widget.post.text!.isEmpty && widget.post.media!.isEmpty;

  @override
  Widget build(BuildContext context) {
    return _deleted ? const SizedBox() : widget.isSkeleton ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 20,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SkeletonLine(
                    style: SkeletonLineStyle(
                      width: MediaQuery.of(context).size.width * 0.10,
                      height: 20,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          SkeletonParagraph(
            style: const SkeletonParagraphStyle(
              spacing: 10,
              lines: 2,
            ),
          ),
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
          Text(
            widget.post.text ?? '',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 20,
            ),
          ),
          if (_getUrl() != null) ...[
            const SizedBox(height: 10),
              UrlPreviewComponent(
                url: _getUrl()!,
            ),
          ],
          if (widget.showToolbar) ...[
            const SizedBox(height: 10),
            ToolBar(
                post: widget.post,
                onMenuTap: _handleMenuTap,
                onLikeTap: toggleLike,
                onRefeedTap: refeed,
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
            onTap: () => Navigator.of(context).pushNamed('/profile', arguments: post.user!.uid),
            child: ProfileAvatarComponent(
              image: post.user!.smallProfilePictureUrl ?? '',
              size: 50,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onProfileTap,
                child: Text(
                  post.user!.name ?? post.user!.username!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                post.feed!.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            timeago.format(post.createdAt!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolBar extends StatelessWidget {
  final Post post;
  final Function onMenuTap;
  final Function onLikeTap;
  final Function onRefeedTap;
  const ToolBar({super.key, required this.post, required this.onMenuTap, required this.onLikeTap, required this.onRefeedTap});

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
                  onPressed: () => onLikeTap,
                  icon: Icon(
                    post.liked ? SolarIconsBold.heart : SolarIconsOutline.heart,
                    color: post.liked ? color : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
                Text(
                  '${post.likes ?? 0}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onRefeedTap,
                  icon: Icon(
                    post.reFeeded ? SolarIconsBold.refreshSquare : SolarIconsOutline.refreshSquare,
                    color: post.reFeeded ? color : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
                Text(
                  '${post.reFeeds ?? 0}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            IconButton(
                onPressed: () => onMenuTap,
                icon: Icon(
                    SolarIconsOutline.menuDots,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                ),
            ),
          ],
        ),
        Divider(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
          thickness: 1,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}



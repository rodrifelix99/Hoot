import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/feed.dart';
import '../services/feed_provider.dart';

class PostComponent extends StatefulWidget {
  final Post post;
  final bool isSoloRefeed;
  final VoidFutureCallBack? onRefeed;
  final bool isSkeleton;
  const PostComponent({super.key, required this.post, this.isSoloRefeed = false, this.onRefeed, this.isSkeleton = false});

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
            Navigator.of(context).pushNamed('/report', arguments: [widget.post.user, widget.post.id, widget.post.feed?.id]);
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
              const SkeletonAvatar(),
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
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: !widget.isSoloRefeed ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEmptyRefeed() ? Row(
                children: [
                  const LineIcon(LineIcons.syncIcon, color: Colors.grey),
                  const SizedBox(width: 5),
                  const Text('Refeeded by ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: _handleProfileTap,
                    child: Text(widget.post.user!.name!, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              ) : Row(
                children: [
                  GestureDetector(
                      onTap: _handleProfileTap,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular((widget.post.user?.radius ?? 100)/3),
                          border: Border.all(
                            color: widget.post.feed?.color ?? Colors.transparent,
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: ProfileAvatar(image: widget.post.user?.smallProfilePictureUrl ?? '', size: 50, radius: (widget.post.user?.radius ?? 100)/3),
                      )
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: _handleProfileTap,
                          child: NameComponent(user: widget.post.user!, feedName: widget.post.feed?.title ?? '', color: widget.post.feed?.color ?? Colors.blue)
                      ),
                      Text(
                        timeago.format(widget.post.createdAt ?? DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _handleMenuTap,
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              widget.post.text != null && widget.post.text!.isNotEmpty ? const SizedBox(height: 20) : const SizedBox(),
              widget.post.text != null && widget.post.text!.isNotEmpty ? Text(
                widget.post.text ?? '',
                style: Theme.of(context).textTheme.titleSmall,
              ) : const SizedBox(),
              const SizedBox(height: 10),
              widget.post.media != null && widget.post.media!.isNotEmpty ? Container(
                constraints: const BoxConstraints(maxHeight: 400, minHeight: 100, maxWidth: double.infinity, minWidth: 100),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Swiper(
                  itemCount: widget.post.media!.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ImageComponent(url: widget.post.media![index], width: double.infinity)
                    );
                  },
                  loop: widget.post.media!.length >= 5,
                  pagination: widget.post.media!.length > 1 ? SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: DotSwiperPaginationBuilder(
                      color: Colors.white,
                      activeColor: widget.post.feed?.color ?? Colors.blue,
                    ),
                  ) : null,
                ),
              ) : const SizedBox(),
              _getUrl() != null ? UrlPreviewComponent(url: _getUrl()!) : const SizedBox(),
              widget.post.reFeededFrom != null && !_isEmptyRefeed() ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/post', arguments: [widget.post.reFeededFrom!.user!.uid, widget.post.reFeededFrom!.feedId, widget.post.reFeededFrom!.id]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ReFeeded from',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        PostComponent(post: widget.post.reFeededFrom!, isSoloRefeed: false, onRefeed: _deletePost)
                      ],
                    ),
                  ),
                ),
              ) : _isEmptyRefeed() ? PostComponent(post: widget.post.reFeededFrom!, isSoloRefeed: true, onRefeed: _deletePost) : const SizedBox(),
              !_isEmptyRefeed() ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: toggleLike,
                        color: widget.post.liked ? widget.post.feed?.color ?? Colors.red : null,
                        icon: widget.post.liked ? LineIcon(LineIcons.heartAlt) : LineIcon(LineIcons.heart)
                      ),
                      Text(
                        widget.post.likes?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      IconButton(
                          onPressed: widget.onRefeed ?? (widget.post.feed?.private != true ? refeed : null),
                          icon: LineIcon(LineIcons.syncIcon, color: widget.post.reFeeded ? widget.post.feed?.color ?? Colors.blue : null, size: 25),
                      ),
                      Text(
                        widget.post.reFeeds?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  /*const SizedBox(width: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => ToastService.showToast(context, 'Coming soon', false),
                        icon: const Icon(Icons.comment_rounded),
                      ),
                      Text(
                        widget.post.comments?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),*/
                ],
              ) : const SizedBox(),
            ],
          ),
        ),
        !widget.isSoloRefeed ? const Divider(
          thickness: 1,
        ) : const SizedBox(),
      ],
    );
  }
}

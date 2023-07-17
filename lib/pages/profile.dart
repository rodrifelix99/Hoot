import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../components/post_component.dart';
import '../models/post.dart';

class ProfilePage extends StatefulWidget {
  final U? user;
  final String feedId;
  const ProfilePage({super.key, this.user, this.feedId = ''});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AuthProvider _authProvider;
  late FeedProvider _feedProvider;
  late U _user;
  late bool _isCurrentUser;
  int _selectedFeedIndex = 0;
  bool _loadingFeeds = false;
  bool _loadingUser = false;

  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _user = widget.user ?? _authProvider.user!;
    _isCurrentUser = _user.uid == _authProvider.user!.uid;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 260),
      vsync: this,
    );
    final curvedAnimation = CurvedAnimation(curve: Curves.decelerate, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
    widget.feedId.isNotEmpty ? _getFeeds(feedToFocus: widget.feedId) : _getFeeds();
  }

  Future _signOut() async {
    // show confirmation dialog
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.signOut),
        content: Text(AppLocalizations.of(context)!.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.signOut),
          ),
        ],
      ),
    );
    if (result == true) {
      await _authProvider.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future _getFeeds({bool refresh = false, String? feedToFocus}) async {
    if (refresh || _user.feeds == null || _user.feeds!.isEmpty) {
      setState(() => _loadingFeeds = true);
      List<Feed> feeds = await _feedProvider.getFeeds(_user.uid);
      if (_isCurrentUser) _authProvider.addAllFeedsToUser(feeds);
      setState(() {
        _user.feeds = feeds;
        feedToFocus != null ? _selectedFeedIndex = _user.feeds!.indexWhere((feed) => feed.id == feedToFocus) : 0;
      });
    } else {
      setState(() => feedToFocus != null ? _selectedFeedIndex = _user.feeds!.indexWhere((feed) => feed.id == feedToFocus) : 0);
    }
    setState(() => _loadingFeeds = false);
  }

  bool _isSubscribedToFeed() {
    return _user.feeds![_selectedFeedIndex].subscribers?.contains(_authProvider.user!.uid) ?? false;
  }

  bool _hasRequestedToJoinFeed() {
    return _user.feeds![_selectedFeedIndex].requests?.contains(_authProvider.user!.uid) ?? false;
  }

  Future _subscribeToFeed() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.subscribe),
          content: Text(AppLocalizations.of(context)!.subscribeConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.subscribe),
            ),
          ],
        )
    );
    if (confirm) {
      setState(() =>  _user.feeds![_selectedFeedIndex].subscribers!.add(_authProvider.user!.uid));
      bool res = await _feedProvider.subscribeToFeed(_user.uid, _user.feeds![_selectedFeedIndex].id);
      !res ? setState(() {
        _user.feeds![_selectedFeedIndex].subscribers!.remove(_authProvider.user!.uid);
        ToastService.showToast(context, AppLocalizations.of(context)!.errorSubscribing, true);
      }) : null;
    }
  }

  Future _unsubscribeFromFeed() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.unsubscribe),
          content: Text(AppLocalizations.of(context)!.unsubscribeConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.unsubscribe),
            ),
          ],
        )
    );
    if (confirm) {
      setState(() =>_user.feeds![_selectedFeedIndex].subscribers!.remove(_authProvider.user!.uid));
      bool res = await _feedProvider.unsubscribeFromFeed(_user.uid, _user.feeds![_selectedFeedIndex].id);
      !res ? setState(() {
        _user.feeds![_selectedFeedIndex].subscribers!.add(_authProvider.user!.uid);
        ToastService.showToast(context, AppLocalizations.of(context)!.errorUnsubscribing, true);
      }) : null;
    }
  }

  Future _requestToJoinFeed() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.requestToJoin),
          content: Text(AppLocalizations.of(context)!.requestToJoinConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.requestToJoin),
            ),
          ],
        )
    );
    if (confirm) {
      setState(() => _user.feeds![_selectedFeedIndex].requests!.add(_authProvider.user!.uid));
      bool res = await _feedProvider.requestToJoinFeed(_user.uid, _user.feeds![_selectedFeedIndex].id);
      !res ? setState(() {
        _user.feeds![_selectedFeedIndex].requests!.remove(_authProvider.user!.uid);
        ToastService.showToast(context, AppLocalizations.of(context)!.errorRequestingToJoin, true);
      }) : null;
    }
  }

  _refreshUser() async {
    setState(() => _loadingUser = true);
    await _authProvider.getUserInfo();
    await _getFeeds(refresh: true);
    setState(() => _loadingUser = false);
  }

  Feed? _mostSubscribedFeed() {
    Feed mostSubscribed = _user.feeds!.first;
    _user.feeds!.forEach((feed) {
      if (feed.subscribers!.length > mostSubscribed.subscribers!.length) mostSubscribed = feed;
    });
    if (mostSubscribed.subscribers!.isEmpty) return null;
    return mostSubscribed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user.name!),
        actions: _isCurrentUser ? [
          IconButton(
            onPressed: _refreshUser,
            icon: const LineIcon(LineIcons.alternateSync),
          ),
          IconButton(
            onPressed: _signOut,
            icon: const LineIcon(LineIcons.alternateSignOut),
          ),
        ] : null,
      ),
      floatingActionButton: _isCurrentUser && _user.feeds!.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: FloatingActionBubble(
            items: <Bubble>[
              Bubble(
                title: AppLocalizations.of(context)!.numberOfSubscribers(_user.feeds![_selectedFeedIndex].subscribers!.length),
                iconColor:  _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                bubbleColor : _user.feeds![_selectedFeedIndex].color!,
                icon: LineIcons.users,
                titleStyle:TextStyle(fontSize: 16, color: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                onPress: () {
                  ToastService.showToast(context, AppLocalizations.of(context)!.comingSoon, false);
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: AppLocalizations.of(context)!.editFeed,
                iconColor:  _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                bubbleColor : _user.feeds![_selectedFeedIndex].color!,
                icon: LineIcons.pencilRuler,
                titleStyle:TextStyle(fontSize: 16, color: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                onPress: () {
                  Navigator.of(context).pushNamed('/edit_feed', arguments: _user.feeds![_selectedFeedIndex]);
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: AppLocalizations.of(context)!.appName,
                iconColor:  _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                bubbleColor : _user.feeds![_selectedFeedIndex].color!,
                icon: LineIcons.feather,
                titleStyle: TextStyle(fontSize: 16, color: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                onPress: () {
                  Navigator.of(context).pushNamed('/create_post', arguments: _user.feeds![_selectedFeedIndex].id);
                  _animationController.reverse();
                },
              ),
            ],
            animation: _animation,
            onPress: () => _animationController.isCompleted
                ? _animationController.reverse()
                : _animationController.forward(),
            iconColor: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            iconData: Icons.menu_rounded,
            backGroundColor: _user.feeds![_selectedFeedIndex].color!,
          )
      ) : null,
      body: _loadingUser ? Center(
          child: LoadingAnimationWidget.inkDrop(
            color: Theme.of(context).colorScheme.onSurface,
            size: 50,
          )
      ) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ImageComponent(
                  url: _user.bannerPictureUrl ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: -75,
                  left: 10,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular((_user.radius ?? 100) + 5)),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 5,
                        ),
                      ),
                      child: ProfileAvatar(image: _user.largeProfilePictureUrl ?? '', size: 150, preview: true, radius: _user.radius ?? 100)
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _isCurrentUser ? ElevatedButton(
                    style: ElevatedButtonTheme.of(context).style?.copyWith(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                      foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondary),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed('/edit_profile'),
                    child: Text(AppLocalizations.of(context)!.editProfile),
                  ) : const SizedBox(height: 50),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NameComponent(user: _user, showUsername: true, size: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _user.bio?.isNotEmpty ?? false ? const SizedBox(height: 10) : const SizedBox(),
                      _user.bio?.isNotEmpty ?? false ? Text(
                          _user.bio ?? ''
                      ) : const SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/subscriptions', arguments: _user.uid),
                            child: Text(AppLocalizations.of(context)!.numberOfSubscriptions(_user.subscriptions.length)),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                  children: [
                    _isCurrentUser ? GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/create_feed'),
                      child: Chip(
                        label: LineIcon(LineIcons.plus, color: Theme.of(context).colorScheme.primary, size: 16),
                      ),
                    ) : const SizedBox(),
                    const SizedBox(width: 10),
                    _loadingFeeds ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ) : const SizedBox(),
                    for (Feed feed in _user.feeds ?? []) Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedFeedIndex = _user.feeds?.indexOf(feed) ?? 0),
                          onForcePressStart: (details) => Vibration.vibrate(),
                          onForcePressPeak: (details) => Navigator.of(context).pushNamed('/feed', arguments: feed),
                          child: _selectedFeedIndex == _user.feeds?.indexOf(feed) ? Chip(
                            label: Text(feed.title),
                            avatar: feed.nsfw == true ? LineIcon(LineIcons.exclamationTriangle, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : feed.private == true ? LineIcon(LineIcons.lock, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
                            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            ),
                            backgroundColor: feed.color,
                          ) : Chip(
                            avatar: feed.nsfw == true ? LineIcon(LineIcons.exclamationTriangle, color: Theme.of(context).colorScheme.primary) : feed.private == true ? LineIcon(LineIcons.lock, color: Theme.of(context).colorScheme.primary) : null,
                            label: Text(feed.title),
                            // avatar: LineIcon(LineIcons.user)
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ]
              ),
            ),
            _user.feeds!.isNotEmpty ?
            Column(
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(child: Text(_user.feeds![_selectedFeedIndex].description!, style: Theme.of(context).textTheme.bodyLarge)),
                      _isCurrentUser ? _user.feeds![_selectedFeedIndex].requests?.isNotEmpty ?? false ? ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed('/feed_requests', arguments: _user.feeds![_selectedFeedIndex].id),
                        style: ElevatedButtonTheme.of(context).style?.copyWith(
                          backgroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color),
                          foregroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                        ),
                        child: Text("${_user.feeds![_selectedFeedIndex].requests!.length} requests"),
                      ) : const SizedBox() : Container(
                        child: _isSubscribedToFeed() ? ElevatedButton(
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.error),
                            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onError),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                          ),
                          onPressed: _unsubscribeFromFeed,
                          child: Text(AppLocalizations.of(context)!.unsubscribe),
                        ) : _user.feeds![_selectedFeedIndex].private == false ? ElevatedButton(
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                            backgroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color),
                            foregroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                          ),
                          onPressed: _subscribeToFeed,
                          child: Text(AppLocalizations.of(context)!.subscribe),
                        ) : _hasRequestedToJoinFeed() ? ElevatedButton(
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                            backgroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color?.withOpacity(0.5)),
                            foregroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                          ),
                          onPressed: () {},
                          child: const Text("Requested"),
                        ) : ElevatedButton(
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                            backgroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color),
                            foregroundColor: MaterialStateProperty.all(_user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                          ),
                          onPressed: _requestToJoinFeed,
                          child: const Text("Request"),
                        ),
                      )
                    ],
                  ),
                ),
                FeedPosts(user: _user, feedIndex: _selectedFeedIndex),
              ],
            )
                : NothingToShowComponent(
              icon: const LineIcon(LineIcons.newspaperAlt),
              text: "${!_isCurrentUser ? AppLocalizations.of(context)!.noFeeds(_user.name ?? _user.username ?? 'This user') : AppLocalizations.of(context)!.noFeedsYou}\n${_isCurrentUser ? AppLocalizations.of(context)!.createFeedMessage : ''}",
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class FeedPosts extends StatefulWidget {
  final U user;
  final int feedIndex;
  const FeedPosts({super.key, required this.user, required this.feedIndex}) : super();

  @override
  State<FeedPosts> createState() => _FeedPostsState();
}

class _FeedPostsState extends State<FeedPosts> {
  late FeedProvider _feedProvider;
  late AuthProvider _authProvider;
  bool _isLoading = true;

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    widget.user.feeds?[widget.feedIndex].posts == null ? _getPosts(DateTime.now()) : setState(() => _isLoading = false);
  }

  @override
  void didUpdateWidget(covariant FeedPosts oldWidget) {
    if (widget.user.feeds?[widget.feedIndex].posts == null || widget.user.feeds?[widget.feedIndex].posts?.isEmpty == true) {
      _getPosts(DateTime.now());
    }
    super.didUpdateWidget(oldWidget);
  }

  _getPosts(DateTime startAfter) async {
    List<Post> posts = await _feedProvider.getPosts(startAfter, widget.user, widget.user.feeds![widget.feedIndex]);
    widget.user.feeds?[widget.feedIndex].posts = posts;
    setState(() => _isLoading = false);
  }

  bool _hasAccessToFeed() {
    if (widget.user.uid == _authProvider.user?.uid)  return true;
    if (widget.user.feeds?[widget.feedIndex].private == true && !_isSubscribed()) {
      return false;
    } else {
      return true;
    }
  }

  bool _isSubscribed() {
    if (widget.user.uid == _authProvider.user?.uid)  return true;
    if (widget.user.feeds?[widget.feedIndex].subscribers?.contains(_authProvider.user?.uid) == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator()) : !_hasAccessToFeed() ?
    Center(
      child: NothingToShowComponent(
          icon: const Icon(Icons.lock_rounded),
          text: '${AppLocalizations.of(context)?.thisFeedIsPrivate}\n\n${AppLocalizations.of(context)?.onlyMembersCanSee(widget.user.name ?? widget.user.username ?? 'this user')}',
      ),
    ) :
    widget.user.feeds?[widget.feedIndex].posts?.isNotEmpty == true ? Column(
      children: [
        for (Post post in widget.user.feeds?[widget.feedIndex].posts ?? []) PostComponent(post: post),
      ],
    ) : widget.user.uid != _authProvider.user?.uid ? Center(
      child: NothingToShowComponent(
        icon: const Icon(Icons.article_rounded),
        text: '${AppLocalizations.of(context)?.emptyFeed}\n\n${AppLocalizations.of(context)?.emptyFeedToOtherUsers(widget.user.name ?? widget.user.username ?? 'this user')}}',
      ),
    ) : Center(
      child: NothingToShowComponent(
        icon: const Icon(Icons.article_rounded),
        text: '${AppLocalizations.of(context)?.emptyFeed}\n\n${AppLocalizations.of(context)?.emptyFeedDescription}',
      ),
    );
  }
}

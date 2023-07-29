import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/subscribe_component.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
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
      duration: const Duration(milliseconds: 260),
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

  _refreshUser() async {
    setState(() => _loadingUser = true);
    await _authProvider.getUserInfo();
    await _getFeeds(refresh: true);
    setState(() => _loadingUser = false);
  }

  Feed? _mostSubscribedFeed() {
    if ((_user.feeds?.length ?? 0) <= 1) return null;
    Feed mostSubscribed = _user.feeds!.first;
    _user.feeds!.forEach((feed) {
      if (feed.subscribers!.length > mostSubscribed.subscribers!.length) mostSubscribed = feed;
    });
    if (mostSubscribed.subscribers!.isEmpty || mostSubscribed.subscribers!.length == 1) return null;
    return mostSubscribed;
  }

  Widget _profileIntro() => Stack(
    clipBehavior: Clip.none,
    children: [
      _user.bannerPictureUrl != null ? ImageComponent(
        url: _user.bannerPictureUrl ?? '',
        height: MediaQuery.of(context).size.height / 2 > 250 ? MediaQuery.of(context).size.height / 2 : 250,
        width: double.infinity,
        fit: BoxFit.cover,
      ) : Container(
        height: 200,
        width: double.infinity,
        color: Colors.black,
      ),
      Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(1),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0),
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // if can go back
                Navigator.canPop(context) ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const LineIcon(LineIcons.arrowLeft, color: Colors.white, size: 30),
                ) : const SizedBox(),
                const Spacer(),
                TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/subscriptions', arguments: _user.uid),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(_user.subscriptions.length.toString(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                        const SizedBox(width: 5),
                        const LineIcon(LineIcons.users, color: Colors.white, size: 30)
                      ],
                    )
                ),
                _isCurrentUser ? const SizedBox(width: 10) : const SizedBox(),
                _isCurrentUser ? IconButton(
                  onPressed: () => _signOut(),
                  icon: const LineIcon(LineIcons.alternateSignOut, color: Colors.white, size: 30),
                ) : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(1),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 10,
        right: 10,
        left: 15 + 150 + 15,
        child: NameComponent(user: _user, showUsername: true, size: 20, textColor: Colors.white),
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
  );
  Widget _profileActions() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _isCurrentUser ? ElevatedButton(
          style: ElevatedButtonTheme.of(context).style?.copyWith(
            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary.withOpacity(0.15)),
            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          ),
          onPressed: () => Navigator.of(context).pushNamed('/edit_profile'),
          child: Text(AppLocalizations.of(context)!.editProfile),
        ) : IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          style: ElevatedButtonTheme.of(context).style?.copyWith(
            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary.withOpacity(0.15)),
            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: () => ToastService.showToast(context, AppLocalizations.of(context)!.comingSoon, false),
        ),
      ],
    ),
  );
  Widget _profileInfo() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _user.bio?.isNotEmpty ?? false ? const SizedBox(height: 10) : const SizedBox(),
        _user.bio?.isNotEmpty ?? false ? Text(
            _user.bio ?? ''
        ) : const SizedBox(),
        _mostSubscribedFeed() != null ? const SizedBox(height: 10) : const SizedBox(),
        _mostSubscribedFeed() != null ? Text(
          AppLocalizations.of(context)!.betterKnownForFeed(_mostSubscribedFeed()?.title ?? ''),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ) : const SizedBox(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isCurrentUser && _user.feeds!.isNotEmpty ? FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: AppLocalizations.of(context)!.numberOfSubscribers(_user.feeds![_selectedFeedIndex].subscribers?.length ?? 0),
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
      ) : null,
      body: _loadingUser ? Center(
          child: LoadingAnimationWidget.inkDrop(
            color: Theme.of(context).colorScheme.onSurface,
            size: 50,
          )
      ) : SmartRefresher(
        header: MaterialClassicHeader(
          color: Theme.of(context).colorScheme.primary,
        ),
        controller: _refreshController,
        onRefresh: () => _refreshUser(),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _profileIntro(),
              _profileActions(),
              _profileInfo(),
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
                        const SizedBox(width: 10),
                        SubscribeComponent(feed: _user.feeds![_selectedFeedIndex], user: _user),
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
    setState(() => _isLoading = true);
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
        buttonText: AppLocalizations.of(context)?.createPost,
        buttonAction: () => Navigator.of(context).pushNamed('/create_post', arguments: widget.user.feeds![widget.feedIndex].id),
      ),
    );
  }
}

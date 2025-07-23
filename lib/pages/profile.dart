import 'package:hoot/app/routes/app_routes.dart';
import 'package:animations/animations.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/components/subscribe_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/post.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/models/user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:vibration/vibration.dart';

import 'package:hoot/components/post_component.dart';
import 'package:hoot/models/post.dart';

class ProfilePage extends StatefulWidget {
  final U? user;
  final String feedId;
  const ProfilePage({super.key, this.user, this.feedId = ''});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AuthController _authProvider;
  late FeedController _feedProvider;
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
    _authProvider = Get.find<AuthController>();
    _feedProvider = Get.find<FeedController>();
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
    _setSubscribers();
  }

  Future _setSubscribers() async {
    if (_user.subscriptions.isEmpty) {
      int subscriptions = await _authProvider.getSubscriptionsCount(_user.uid);
      setState(() => _user.subscriptions = List<String>.filled(subscriptions, ''));
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
    for (var feed in _user.feeds ?? []) {
      if ((feed.subscribers ?? []).length > (mostSubscribed.subscribers ?? []).length) mostSubscribed = feed;
    }
    if ((mostSubscribed.subscribers ?? []).isEmpty || (mostSubscribed.subscribers ?? []).length == 1) return null;
    return mostSubscribed;
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const LineIcon(LineIcons.userShield),
              title: Text('reportUsername'.trParams({'value': _user.username ?? ''})),
              onTap: () =>
              {
                Get.back(),
                Get.toNamed('/report', arguments: [_user])
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const LineIcon(LineIcons.removeUser),
              title: Text('blockUser'.trParams({'value': _user.username ?? ''})),
              onTap: () => {
                Get.back(),
                ToastService.showToast(
                    context, 'comingSoon'.tr, false)
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
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
              borderRadius: const BorderRadius.all(Radius.circular(55)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 25,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ProfileAvatarComponent(image: _user.largeProfilePictureUrl ?? '', size: 150, preview: true)
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
          onPressed: () => Get.toNamed('/edit_profile'),
          child: Text('editProfile'.tr),
        ) : IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          style: ElevatedButtonTheme.of(context).style?.copyWith(
            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary.withOpacity(0.15)),
            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: _showContextMenu,
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
          'betterKnownForFeed'.trParams({'value': _mostSubscribedFeed(})?.title ?? ''),
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
      appBar: AppBarComponent(
        backgroundColor: Colors.black.withOpacity(0.25),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
              onPressed: () => Get.toNamed('/subscriptions', arguments: _user.uid),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_user.subscriptions.length.toString(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                  const SizedBox(width: 5),
                  const Icon(SolarIconsBold.usersGroupRounded, color: Colors.white, size: 25)
                ],
              )
          ),
          _isCurrentUser ? IconButton(
            onPressed: () => Get.offAllNamed('/settings', (route) => false),
            icon: const Icon(SolarIconsBold.settings, color: Colors.white, size: 30),
          ) : const SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: _isCurrentUser && _user.feeds != null && _user.feeds!.isNotEmpty ? FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: 'numberOfSubscribers'.trParams({'value': _user.feeds![_selectedFeedIndex].subscribers?.length ?? 0}),
            iconColor:  _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            bubbleColor : _user.feeds![_selectedFeedIndex].color!,
            icon: SolarIconsOutline.usersGroupRounded,
            titleStyle:TextStyle(fontSize: 16, color: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
            onPress: () {
              Get.toNamed('/subscribers', arguments: _user.feeds![_selectedFeedIndex].id);
              _animationController.reverse();
            },
          ),
          Bubble(
            title: 'editFeed'.tr,
            iconColor:  _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            bubbleColor : _user.feeds![_selectedFeedIndex].color!,
            icon: SolarIconsOutline.pen,
            titleStyle:TextStyle(fontSize: 16, color: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
            onPress: () {
              Get.toNamed('/edit_feed', arguments: _user.feeds![_selectedFeedIndex]);
              _animationController.reverse();
            },
          ),
          Bubble(
            title: 'appName'.tr,
            iconColor:  _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            bubbleColor : _user.feeds![_selectedFeedIndex].color!,
            icon: SolarIconsOutline.addSquare,
            titleStyle: TextStyle(fontSize: 16, color: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white),
            onPress: () {
              Get.toNamed('/create_post', arguments: _user.feeds![_selectedFeedIndex].id);
              _animationController.reverse();
            },
          ),
        ],
        animation: _animation,
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: _user.feeds![_selectedFeedIndex].color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        iconData: SolarIconsOutline.hamburgerMenu,
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
                      _isCurrentUser && (_authProvider.user?.feeds?.length ?? 0) < 25 ? GestureDetector(
                        onTap: () => Get.toNamed('/create_feed'),
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
                            onForcePressPeak: (details) => Get.toNamed('/feed', arguments: feed),
                            child: _selectedFeedIndex == _user.feeds?.indexOf(feed) ? Chip(
                              label: Text(feed.title),
                              avatar: feed.nsfw == true ? LineIcon(LineIcons.exclamationTriangle, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : feed.private == true ? LineIcon(LineIcons.lock, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : feed.verified == true ? Icon(Icons.verified_rounded, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
                              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                              ),
                              backgroundColor: feed.color,
                            ) : Chip(
                              avatar: feed.nsfw == true ? LineIcon(LineIcons.exclamationTriangle, color: Theme.of(context).colorScheme.primary) : feed.private == true ? LineIcon(LineIcons.lock, color: Theme.of(context).colorScheme.primary) : feed.verified == true ? Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary) : null,
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
              _user.feeds != null && _user.feeds!.isNotEmpty ?
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
                text: !_isCurrentUser ? 'noFeeds'.trParams({'value': _user.name ?? _user.username ?? 'This user'}) : 'noFeedsYou'.tr,
                buttonText: _isCurrentUser ? 'createFeed'.tr : null,
                buttonAction: () => Get.toNamed('/create_feed'),
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
  late FeedController _feedProvider;
  late AuthController _authProvider;
  bool _isLoading = true;

  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    _authProvider = Get.find<AuthController>();
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
    if (startAfter.isAfter(DateTime.now().subtract(const Duration(seconds: 5)))) {
      widget.user.feeds![widget.feedIndex].posts = posts;
    } else {
      widget.user.feeds![widget.feedIndex].posts?.addAll(posts);
    }
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
        text: 'thisFeedIsPrivate'.tr +
            '\n\n' +
            'onlyMembersCanSee'.trParams({'displayName': widget.user.name ?? widget.user.username ?? 'this user'}),
      ),
    ) :
    widget.user.feeds?[widget.feedIndex].posts?.isNotEmpty == true ? Column(
      children: [
        for (Post post in widget.user.feeds?[widget.feedIndex].posts ?? []) ...[
            OpenContainer(
              closedElevation: 0,
              closedColor: Theme.of(context).colorScheme.surface,
              closedBuilder: (context, action) => PostComponent(post: post),
              openBuilder: (context, action) => PostPage(post: post)
          ),
        ],
        if (widget.user.feeds![widget.feedIndex].posts!.length % 10 == 0) ...[
          const SizedBox(height: 10),
          IconButton(
            onPressed: () => _getPosts(widget.user.feeds![widget.feedIndex].posts!.last.createdAt ?? DateTime.now()),
            icon: Icon(SolarIconsBold.arrowDown),
          ),
        ],
      ],
    ) : widget.user.uid != _authProvider.user?.uid ? Center(
      child: NothingToShowComponent(
        icon: const Icon(Icons.article_rounded),
        text: 'emptyFeed'.tr +
            '\n\n' +
            'emptyFeedToOtherUsers'.trParams({'displayName': widget.user.name ?? widget.user.username ?? 'this user'}),
      ),
    ) : Center(
      child: NothingToShowComponent(
        icon: const Icon(Icons.article_rounded),
        text: 'emptyFeed'.tr + '\n\n' + 'emptyFeedDescription'.tr,
        buttonText: 'createPost'.tr,
        buttonAction: () => Get.toNamed('/create_post', arguments: widget.user.feeds![widget.feedIndex].id),
      ),
    );
  }
}

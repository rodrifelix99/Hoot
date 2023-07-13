import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/follow_button.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final U? user;
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthProvider _authProvider;
  late FeedProvider _feedProvider;
  late U _user;
  late bool _isCurrentUser;
  int _selectedFeedIndex = 0;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _user = widget.user ?? _authProvider.user!;
    _isCurrentUser = _user.uid == _authProvider.user!.uid;
    super.initState();
    _getFeeds();
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

  Future _getFeeds() async {
    if (_user.feeds == null || _user.feeds!.isEmpty) {
      List<Feed> feeds = await _feedProvider.getFeeds(_user.uid);
      if (_isCurrentUser) _authProvider.addAllFeedsToUser(feeds);
      setState(() {
        _user.feeds = feeds;
        _selectedFeedIndex = 0;
      });
    } else {
      setState(() => _selectedFeedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_user.name!),
          actions: [
            if (_isCurrentUser) IconButton(
              onPressed: _signOut,
              icon: const LineIcon(LineIcons.alternateSignOut),
            ),
          ],
        ),
        body: SingleChildScrollView(
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
                    ) : FollowButton(userId: _user.uid),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        _user.name!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )
                    ),
                    Text(
                        '@${_user.username}',
                        style: Theme.of(context).textTheme.bodySmall
                    ),
                    _user.bio != null ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _user.bio!.isNotEmpty ? const SizedBox(height: 10) : const SizedBox(),
                        Text(
                            _user.bio ?? ''
                        ),
                      ],
                    ) : const SizedBox(),
                  ],
                ),
              ),
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
                      for (Feed feed in _user.feeds ?? []) Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _selectedFeedIndex = _user.feeds?.indexOf(feed) ?? 0),
                            child: _selectedFeedIndex == _user.feeds?.indexOf(feed) ? Chip(
                              label: Text(feed.title),
                              avatar: feed.private == true ? LineIcon(LineIcons.lock, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : feed.nsfw == true ? LineIcon(LineIcons.exclamationTriangle, color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
                              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: feed.color!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                              ),
                              backgroundColor: feed.color,
                            ) : Chip(
                              avatar: feed.private == true ? LineIcon(LineIcons.lock, color: Theme.of(context).colorScheme.primary) : feed.nsfw == true ? LineIcon(LineIcons.exclamationTriangle, color: Theme.of(context).colorScheme.primary) : null,
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
              const SizedBox(height: 10),
              const NothingToShowComponent(
                  icon: Icon(Icons.post_add_rounded),
                  text: "In the future, you'll see here the posts of this user"
              )
            ],
          ),
        )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/follow_button.dart';
import 'package:hoot/components/image_component.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final U? user;
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late U _user;
  late bool _isCurrentUser;

  @override
  void initState() {
    _user = widget.user ?? Provider.of<AuthProvider>(context, listen: false).user!;
    _isCurrentUser = _user.uid == Provider.of<AuthProvider>(context, listen: false).user!.uid;
    super.initState();
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
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
                      const SizedBox(height: 10),
                      Text(
                          _user.bio ?? ''
                      ),
                    ],
                  ) : const SizedBox(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/follow_list', arguments: {'userId': _user.uid, 'following': false}),
                        child: Text(
                          '${_user.followers.length} ${AppLocalizations.of(context)!.followers}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/follow_list', arguments: {'userId': _user.uid, 'following': true}),
                        child: Text(
                          '${_user.following.length} ${AppLocalizations.of(context)!.following}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                  children: [
                    Chip(
                      label: LineIcon(LineIcons.plus, color: Theme.of(context).colorScheme.primary, size: 16)
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: const Text('Personal'),
                      avatar: LineIcon(LineIcons.user, color: Theme.of(context).colorScheme.onPrimary),
                      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('Holidays & Travel'),
                      avatar: LineIcon(LineIcons.plane),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('Food & Drink'),
                      avatar: LineIcon(LineIcons.fruitApple),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('Sports'),
                      avatar: LineIcon(LineIcons.footballBall),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('Music'),
                      avatar: LineIcon(LineIcons.music),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('Movies'),
                      avatar: LineIcon(LineIcons.retroCamera),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('LGBTQ+'),
                      avatar: LineIcon(LineIcons.rainbow),
                    ),
                    const SizedBox(width: 10),
                    const Chip(
                      label: Text('+18 NSFW'),
                      avatar: LineIcon(LineIcons.exclamationTriangle),
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

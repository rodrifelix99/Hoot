import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/follow_button.dart';
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
          children: [
            _user.bannerPictureUrl != null ?
            Image(
              image: NetworkImage(_user.bannerPictureUrl!),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ) :
            const SizedBox(),
            const SizedBox(height: 20),
            ProfileAvatar(image: _user.largeProfilePictureUrl ?? '', size: 150, preview: true),
            const SizedBox(height: 20),
            Text(
              _user.name!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _user.username!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _isCurrentUser ? ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/edit_profile'),
              child: Text(AppLocalizations.of(context)!.editProfile),
            ) : FollowButton(isFollowing: _user.followers.contains(Provider.of<AuthProvider>(context, listen: false).user!.uid)),
          ],
        ),
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/follow_button.dart';
import 'package:provider/provider.dart';
import 'package:hoot/services/auth.dart';
import 'package:hoot/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  U? user;
  ProfilePage({super.key, this.user});

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
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCurrentUser ? AppLocalizations.of(context)!.profile : _user.name!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
              onPressed: _signOut,
              child: Text(AppLocalizations.of(context)!.signOut),
            ) : FollowButton(isFollowing: _user.followers.contains(Provider.of<AuthProvider>(context, listen: false).user!.uid)),
          ],
        ),
      )
    );
  }
}

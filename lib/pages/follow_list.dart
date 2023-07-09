import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/follow_button.dart';
import '../services/auth_provider.dart';

class FollowListPage extends StatefulWidget {
  final String userId;
  final bool following;
  const FollowListPage({super.key, required this.userId, this.following = false});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  List<U> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  Future _getUsers() async {
    List<U> users = await Provider.of<AuthProvider>(context, listen: false).getFollows(widget.userId, widget.following);
    setState(() {
      _isLoading = false;
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.following ? 'Following' : 'Followers'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) :
      _users.length > 0 ? ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          U user = _users[index];
          return ListTile(
            onTap: () => Navigator.pushNamed(context, '/profile', arguments: user),
            leading: ProfileAvatar(image: user.smallProfilePictureUrl ?? '', size: 40),
            trailing: FollowButton(userId: user.uid),
            title: Text(user.name ?? ''),
            subtitle: Text(user.username ?? ''),
          );
        },
      ) : Center(
        child: NothingToShowComponent(
          icon: Icon(Icons.people_rounded),
          text: AppLocalizations.of(context)!.noUsersToShow,
        ),
      )
    );
  }
}

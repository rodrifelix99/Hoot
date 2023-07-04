import 'package:flutter/material.dart';
import 'package:hoot/services/auth.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class UserSuggestions extends StatefulWidget {
  const UserSuggestions({super.key});

  @override
  State<UserSuggestions> createState() => _UserSuggestionsState();
}

class _UserSuggestionsState extends State<UserSuggestions> {
  List<U> _users = [];

  @override
  void initState() {
    _loadUsers();
    super.initState();
  }

  Future _loadUsers() async {
    List<U> users = await Provider.of<AuthProvider>(context, listen: false).getSuggestions();
    if (users.isNotEmpty) {
      setState(() {
        _users = users;
      });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No users found to suggest"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // horizontal list view of all user avatars
    return _users.isEmpty ? const SizedBox() : SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/profile', arguments: _users[index]);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(_users[index].smallProfilePictureUrl!),
                  ),
                ),
                Text(_users[index].username!),
              ],
            ),
          );
        },
      ),
    );
  }
}

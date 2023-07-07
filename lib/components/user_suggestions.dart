import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class UserSuggestions extends StatefulWidget {
  const UserSuggestions({super.key});

  @override
  State<UserSuggestions> createState() => _UserSuggestionsState();
}

class _UserSuggestionsState extends State<UserSuggestions> {
  List<U> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    _loadUsers();
    super.initState();
  }

  Future _loadUsers() async {
    setState(() => _isLoading = true);
    List<U> users = await Provider.of<AuthProvider>(context, listen: false).getSuggestions();
    if (users.isNotEmpty) {
      setState(() {
        _isLoading = false;
        _users = users;
      });
    } else {
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, 'No users found', true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _users.isEmpty && !_isLoading
        ? const SizedBox()
        : SizedBox(
      height: 110,
      width: double.infinity,
      child: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  child: ProfileAvatar(
                    image: _users[index].smallProfilePictureUrl ?? '',
                    size: 60,
                  ),
                ),
                const SizedBox(height: 5),
                Text("@${_users[index].username!}", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}

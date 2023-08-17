import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../models/user.dart';

class UserSuggestions extends StatefulWidget {
  const UserSuggestions({super.key});

  @override
  State<UserSuggestions> createState() => _UserSuggestionsState();
}

class _UserSuggestionsState extends State<UserSuggestions> {
  late AuthProvider _authProvider;
  bool _isLoading = true;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.userSuggestions.isEmpty ? _loadUsers() : null;
    super.initState();
  }

  Future _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      List<U> users = await Provider.of<AuthProvider>(context, listen: false).getSuggestions();
      if (users.isNotEmpty) {
        _authProvider.userSuggestions = users;
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          ToastService.showToast(context, 'No users found', true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _authProvider.userSuggestions.isEmpty && !_isLoading
        ? const SizedBox()
        : SizedBox(
      height: 110,
      width: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _isLoading ? 7 : _authProvider.userSuggestions.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isLoading ? SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(15),
              ),
            ) : Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/profile', arguments: _authProvider.userSuggestions[index]);
                  },
                  child: ProfileAvatarComponent(
                      image: _authProvider.userSuggestions[index].smallProfilePictureUrl ?? '',
                      size: 60
                  ),
                ),
                const SizedBox(height: 5),
                Text("@${_authProvider.userSuggestions[index].username!}", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:skeletons/skeletons.dart';
import '../app/utils/logger.dart';

import 'package:hoot/models/user.dart';

class UserSuggestions extends StatefulWidget {
  const UserSuggestions({super.key});

  @override
  State<UserSuggestions> createState() => _UserSuggestionsState();
}

class _UserSuggestionsState extends State<UserSuggestions> {
  late AuthController _authProvider;
  bool _isLoading = false;

  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    _authProvider.userSuggestions.isEmpty ? _loadUsers() : null;
    super.initState();
  }

  Future _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      List<U> users = await Get.find<AuthController>().getSuggestions();
      if (users.isNotEmpty) {
        _authProvider.userSuggestions = users;
      }
    } catch (e) {
      logError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _authProvider.userSuggestions.isEmpty && !_isLoading
        ? const SizedBox()
        : SizedBox(
            height: 120,
            width: double.infinity,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _isLoading ? 7 : _authProvider.userSuggestions.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isLoading
                      ? SizedBox(
                          width: 60,
                          height: 60,
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('/profile',
                                    arguments:
                                        _authProvider.userSuggestions[index]);
                              },
                              child: ProfileAvatarComponent(
                                  image: _authProvider.userSuggestions[index]
                                          .smallProfilePictureUrl ??
                                      '',
                                  size: 60),
                            ),
                            const SizedBox(height: 5),
                            Text(
                                "@${_authProvider.userSuggestions[index].username!}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5))),
                            Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                              thickness: 1,
                            ),
                          ],
                        ),
                );
              },
            ),
          );
  }
}

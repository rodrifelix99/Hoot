import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/comment.dart';

class CommentComponent extends StatelessWidget {
  final Comment comment;
  const CommentComponent({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProfileAvatarComponent(
        image: comment.user?.smallProfilePictureUrl ?? '',
        size: 32,
        radius: 16,
      ),
      title: comment.user != null
          ? NameComponent(user: comment.user!, size: 14)
          : const SizedBox.shrink(),
      subtitle: Text(comment.text),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/comment.dart';
import 'package:hoot/util/mention_utils.dart';
import 'package:hoot/util/extensions/datetime_extension.dart';

class CommentComponent extends StatelessWidget {
  final Comment comment;
  const CommentComponent({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProfileAvatarComponent(
        image: comment.user?.smallProfilePictureUrl ?? '',
        hash: comment.user?.smallAvatarHash ?? comment.user?.bigAvatarHash,
        size: 32,
      ),
      title: comment.user != null
          ? NameComponent(user: comment.user!, size: 14)
          : const SizedBox.shrink(),
      subtitle: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: parseMentions(comment.text),
        ),
      ),
      trailing: comment.createdAt != null
          ? Text(
              comment.createdAt!.timeAgo(),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/models/user.dart';

class AvatarStack extends StatelessWidget {
  final List<U> users;
  final double size;
  const AvatarStack({super.key, required this.users, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();
    final visible = users.take(3).toList();
    return SizedBox(
      height: size,
      width: size + (visible.length - 1) * (size * 0.6),
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * size * 0.6,
              child: ProfileAvatarComponent(
                image: visible[i].smallProfilePictureUrl ?? '',
                hash: visible[i].smallAvatarHash ?? visible[i].bigAvatarHash,
                size: size.toInt(),
              ),
            ),
        ],
      ),
    );
  }
}

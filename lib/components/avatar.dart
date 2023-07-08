import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:octo_image/octo_image.dart';

class ProfileAvatar extends StatefulWidget {
  final String image;
  final int size;
  final bool preview;
  final String url;
  const ProfileAvatar({super.key, required this.image, required this.size, this.preview = false, this.url = ''});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {

  @override
  Widget build(BuildContext context) {
    if (widget.preview) {
      return FullScreenWidget(
        backgroundColor: Colors.black,
        child: Hero(
          tag: widget.image + widget.url + widget.size.toString(),
          child: Avatar(image: widget.image, size: widget.size),
        ),
      );
    } else {
      return Avatar(image: widget.image, size: widget.size);
    }
  }
}

class Avatar extends StatefulWidget {
  final String image;
  final int size;
  const Avatar({super.key, required this.image, required this.size});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {

  @override
  Widget build(BuildContext context) {
    if (widget.image.isEmpty) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        radius: widget.size.toDouble() / 2,
        child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary, size: widget.size.toDouble() / 2),
      );
    }

    return OctoImage.fromSet(
      image: NetworkImage(widget.image),
      octoSet: OctoSet.circleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        text: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary, size: widget.size.toDouble() / 2),
      ),
      fit: BoxFit.cover,
      height: widget.size.toDouble(),
      width: widget.size.toDouble(),
    );
  }
}

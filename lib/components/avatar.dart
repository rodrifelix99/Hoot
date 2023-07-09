import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:octo_image/octo_image.dart';

class ProfileAvatar extends StatefulWidget {
  final String image;
  final int size;
  final double radius;
  final bool preview;
  final String url;
  const ProfileAvatar({super.key, required this.image, required this.size, this.radius = 100, this.preview = false, this.url = ''});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {

  @override
  Widget build(BuildContext context) {
    if (widget.preview) {
      return FullScreenWidget(
        backgroundColor: Colors.black,
        child: Center(
          child: Hero(
            tag: widget.image + widget.url + widget.size.toString(),
            child: Avatar(image: widget.image, size: widget.size, radius: widget.radius),
          ),
        ),
      );
    } else {
      return Avatar(image: widget.image, size: widget.size, radius: widget.radius);
    }
  }
}

class Avatar extends StatefulWidget {
  final String image;
  final int size;
  final double radius;
  const Avatar({super.key, required this.image, required this.size, required this.radius});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {

  @override
  Widget build(BuildContext context) {
    if (widget.image.isEmpty) {
      return SizedBox(
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          radius: widget.radius.toDouble(),
          child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary, size: widget.size.toDouble() / 2),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.radius.toDouble())),
      child: OctoImage(
        image: NetworkImage(widget.image),
        placeholderBuilder: OctoPlaceholder.blurHash(
          'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
        ),
        errorBuilder: OctoError.blurHash(
          'LPOe[M{tZjj;KnPTowa#4=xtyBbJ',
          icon: null,
          iconColor: Colors.grey.shade800,
        ),
        fit: BoxFit.cover,
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      ),
    );
  }
}

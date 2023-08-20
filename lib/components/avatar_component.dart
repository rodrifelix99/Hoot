import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:octo_image/octo_image.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileAvatarComponent extends StatefulWidget {
  final String image;
  final int size;
  final bool preview;
  final String url;
  final double radius;
  const ProfileAvatarComponent({super.key, required this.image, required this.size, this.preview = false, this.url = '', this.radius = -1});

  @override
  State<ProfileAvatarComponent> createState() => _ProfileAvatarComponentState();
}

class _ProfileAvatarComponentState extends State<ProfileAvatarComponent> {

  @override
  Widget build(BuildContext context) {
    if (widget.preview) {
      return FullScreenWidget(
        backgroundColor: Colors.black,
        child: Center(
          child: Hero(
            tag: widget.image,
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
      return Container(
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: widget.radius == -1 ? BorderRadius.all(Radius.circular(widget.size / 3)) : BorderRadius.all(Radius.circular(widget.radius)),
        ),
        child: Center(
            child: Icon(
                SolarIconsBold.linkRoundAngle,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: widget.size / 2
            ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: widget.radius == -1 ? BorderRadius.all(Radius.circular(widget.size / 3)) : BorderRadius.all(Radius.circular(widget.radius)),
      child: OctoImage(
        image: NetworkImage(widget.image),
        placeholderBuilder: OctoPlaceholder.blurHash(
          'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
        ),
        errorBuilder: OctoError.icon(color: Theme.of(context).colorScheme.error),
        fit: BoxFit.cover,
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      ),
    );
  }
}

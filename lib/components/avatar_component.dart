import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileAvatarComponent extends StatefulWidget {
  final String image;
  final int size;
  final bool preview;
  final String url;
  final String? hash;
  final Color? color;
  final Color? foregroundColor;

  const ProfileAvatarComponent(
      {super.key,
      required this.image,
      required this.size,
      this.preview = false,
      this.url = '',
      this.hash,
      this.color,
      this.foregroundColor});

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
            child: Avatar(
              image: widget.image,
              hash: widget.hash,
              size: widget.size,
              color: widget.color,
              foregroundColor: widget.foregroundColor,
            ),
          ),
        ),
      );
    } else {
      return Avatar(
        image: widget.image,
        hash: widget.hash,
        size: widget.size,
        color: widget.color,
        foregroundColor: widget.foregroundColor,
      );
    }
  }
}

class Avatar extends StatefulWidget {
  final String image;
  final String? hash;
  final int size;
  final Color? color;
  final Color? foregroundColor;

  const Avatar(
      {super.key,
      required this.image,
      this.hash,
      required this.size,
      this.color,
      this.foregroundColor});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    if (widget.image.isEmpty) {
      final bgColor =
          widget.color ?? Theme.of(context).colorScheme.primaryContainer;
      final fgColor = widget.foregroundColor ??
          Theme.of(context).colorScheme.onPrimaryContainer;
      return Container(
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
        clipBehavior: Clip.hardEdge,
        decoration: ShapeDecoration(
          color: bgColor,
          shape: CircleBorder(),
        ),
        child: Center(
          child: Icon(SolarIconsBold.linkRoundAngle,
              color: fgColor, size: widget.size / 2),
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
      ),
      clipBehavior: Clip.hardEdge,
      child: HashCachedImage(
        imageUrl: widget.image,
        hash: widget.hash,
        // When a blur hash is provided, `HashCachedImage` will automatically
        // render the blurred placeholder while loading. Removing the custom
        // placeholder ensures the blur hash is shown instead of an empty box.
        errorWidget: (context, error, stackTrace) => Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
        ),
        fit: BoxFit.cover,
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      ),
    );
  }
}

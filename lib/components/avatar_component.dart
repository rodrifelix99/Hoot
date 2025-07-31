import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileAvatarComponent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (preview) {
      return FullScreenWidget(
        backgroundColor: Colors.black,
        child: Center(
          child: Hero(
            tag: image,
            child: Avatar(
              image: image,
              hash: hash,
              size: size,
              color: color,
              foregroundColor: foregroundColor,
            ),
          ),
        ),
      );
    } else {
      return Avatar(
        image: image,
        hash: hash,
        size: size,
        color: color,
        foregroundColor: foregroundColor,
      );
    }
  }
}

class Avatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      final bgColor =
          color ?? Theme.of(context).colorScheme.primaryContainer;
      final fgColor = foregroundColor ??
          Theme.of(context).colorScheme.onPrimaryContainer;
      return Container(
        height: size.toDouble(),
        width: size.toDouble(),
        clipBehavior: Clip.hardEdge,
        decoration: ShapeDecoration(
          color: bgColor,
          shape: CircleBorder(),
        ),
        child: Center(
          child: Icon(SolarIconsBold.linkRoundAngle,
              color: fgColor, size: size / 2),
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
      ),
      clipBehavior: Clip.hardEdge,
      child: HashCachedImage(
        imageUrl: image,
        hash: hash,
        // When a blur hash is provided, `HashCachedImage` will automatically
        // render the blurred placeholder while loading. Removing the custom
        // placeholder ensures the blur hash is shown instead of an empty box.
        errorWidget: (context, error, stackTrace) => Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
        ),
        fit: BoxFit.cover,
        height: size.toDouble(),
        width: size.toDouble(),
      ),
    );
  }
}

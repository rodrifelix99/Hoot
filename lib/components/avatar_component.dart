import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileAvatarComponent extends StatefulWidget {
  final String image;
  final int size;
  final bool preview;
  final String url;
  final double radius;
  final Color? color;
  final Color? foregroundColor;

  const ProfileAvatarComponent(
      {super.key,
      required this.image,
      required this.size,
      this.preview = false,
      this.url = '',
      this.radius = -1,
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
              size: widget.size,
              radius: widget.radius,
              color: widget.color,
              foregroundColor: widget.foregroundColor,
            ),
          ),
        ),
      );
    } else {
      return Avatar(
        image: widget.image,
        size: widget.size,
        radius: widget.radius,
        color: widget.color,
        foregroundColor: widget.foregroundColor,
      );
    }
  }
}

class Avatar extends StatefulWidget {
  final String image;
  final int size;
  final double radius;
  final Color? color;
  final Color? foregroundColor;

  const Avatar(
      {super.key,
      required this.image,
      required this.size,
      required this.radius,
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
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius:
                  widget.radius == -1 ? widget.size / 3 : widget.radius,
              cornerSmoothing: 1.25,
            ),
          ),
        ),
        child: Center(
          child: Icon(SolarIconsBold.linkRoundAngle,
              color: fgColor, size: widget.size / 2),
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius:
                widget.radius == -1 ? widget.size / 3 : widget.radius,
            cornerSmoothing: 1.25,
          ),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: HashCachedImage(
        imageUrl: widget.image,
        placeholder: (context) => const SizedBox.shrink(),
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

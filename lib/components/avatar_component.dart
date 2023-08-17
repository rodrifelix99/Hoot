import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:octo_image/octo_image.dart';

class ProfileAvatarComponent extends StatefulWidget {
  final String image;
  final int size;
  final bool preview;
  final String url;
  const ProfileAvatarComponent({super.key, required this.image, required this.size, this.preview = false, this.url = ''});

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
            child: Avatar(image: widget.image, size: widget.size),
          ),
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
      return Container(
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(widget.size / 3)),
        ),
        child: Center(child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary, size: widget.size / 2)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.size / 3)),
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

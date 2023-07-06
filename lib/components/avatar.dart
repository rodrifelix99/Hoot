import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:octo_image/octo_image.dart';

class ProfileAvatar extends StatefulWidget {
  String image;
  int size;
  bool preview;
  String url;
  ProfileAvatar({super.key, required this.image, required this.size, this.preview = false, this.url = ''});

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
          child: OctoImage.fromSet(
            image: widget.image.isEmpty ? const NetworkImage('none') : NetworkImage(widget.image),
            octoSet: OctoSet.circleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              text: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary, size: widget.size.toDouble() / 2),
            ),
            fit: BoxFit.cover,
            height: widget.size.toDouble(),
            width: widget.size.toDouble(),
          ),
        ),
      );
    } else {
      return OctoImage.fromSet(
        image: widget.image.isEmpty ? const NetworkImage('none') : NetworkImage(widget.image),
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
}

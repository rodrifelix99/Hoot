import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:hoot/util/routes/app_routes.dart';

class ProfileAvatarComponent extends StatelessWidget {
  final String image;
  final int size;
  final bool preview;
  final String url;
  final String? hash;
  final List<BoxShadow>? boxShadow;

  const ProfileAvatarComponent({
    super.key,
    required this.image,
    required this.size,
    this.preview = false,
    this.url = '',
    this.hash,
    this.boxShadow,
  });

  void _openViewer() {
    Get.toNamed(
      AppRoutes.photoViewer,
      arguments: {'imageUrl': image},
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (preview) {
      return GestureDetector(
        onTap: _openViewer,
        child: Hero(
          tag: image + size.toString(),
          child: Avatar(
            image: image,
            hash: hash,
            size: size,
            boxShadow: boxShadow,
          ),
        ),
      );
    } else {
      return Avatar(
        image: image,
        hash: hash,
        size: size,
        boxShadow: boxShadow,
      );
    }
  }
}

class Avatar extends StatelessWidget {
  final String image;
  final String? hash;
  final int size;
  final List<BoxShadow>? boxShadow;

  const Avatar({
    super.key,
    required this.image,
    this.hash,
    required this.size,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Container(
        height: size.toDouble(),
        width: size.toDouble(),
        clipBehavior: Clip.hardEdge,
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          shadows: boxShadow,
        ),
        child: Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
        shadows: boxShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: HashCachedImage(
        imageUrl: image,
        hash: hash,
        // When a blur hash is provided, `HashCachedImage` will automatically
        // render the blurred placeholder while loading. Removing the custom
        // placeholder ensures the blur hash is shown instead of an empty box.
        errorWidget: (context, error, stackTrace) => Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
        ),
        fit: BoxFit.cover,
        height: size.toDouble(),
        width: size.toDouble(),
      ),
    );
  }
}

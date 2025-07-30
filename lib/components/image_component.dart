import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:hash_cached_image/hash_cached_image.dart';

class ImageComponent extends StatefulWidget {
  final String url;
  final String? hash;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment? alignment;
  final ImageRepeat? repeat;
  final double radius;

  const ImageComponent(
      {super.key,
      required this.url,
      this.hash,
      this.width,
      this.height,
      this.fit,
      this.alignment,
      this.repeat,
      this.radius = 0});

  @override
  State<ImageComponent> createState() => _ImageComponentState();
}

class _ImageComponentState extends State<ImageComponent> {
  void _openViewer() {
    Get.toNamed(
      AppRoutes.photoViewer,
      arguments: {'imageUrl': widget.url},
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        _openViewer();
      },
      child: LiquidGlass(
        shape: LiquidRoundedRectangle(
          borderRadius: Radius.circular(widget.radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: HashCachedImage(
            imageUrl: widget.url,
            hash: widget.hash,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            alignment: widget.alignment ?? Alignment.center,
            repeat: widget.repeat ?? ImageRepeat.noRepeat,
            // Show the blur hash while the image loads instead of a loading
            // animation. Removing the placeholder parameter lets
            // `HashCachedImage` fall back to its default behaviour, which
            // uses the provided blur hash as a placeholder when available.
            errorWidget: (context, error, stackTrace) => Container(
              color: Colors.grey.shade800,
              child: const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

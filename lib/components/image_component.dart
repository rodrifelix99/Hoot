import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageComponent extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment? alignment;
  final ImageRepeat? repeat;
  final double radius;
  const ImageComponent(
      {super.key,
      required this.url,
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
  @override
  Widget build(BuildContext context) {
    return FullScreenWidget(
      backgroundColor: Colors.black,
      child: Center(
        child: Hero(
          tag: widget.url +
              widget.width.toString() +
              widget.height.toString() +
              DateTime.now().toString(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: CachedNetworkImage(
              imageUrl: widget.url,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              alignment: widget.alignment ?? Alignment.center,
              repeat: widget.repeat ?? ImageRepeat.noRepeat,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 50,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';

class ImageComponent extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment? alignment;
  final ImageRepeat? repeat;
  const ImageComponent({super.key, required this.url, this.width, this.height, this.fit, this.alignment, this.repeat});

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
          tag: widget.url + widget.width.toString() + widget.height.toString() + DateTime.now().toString(),
          child: OctoImage(
              image: NetworkImage(widget.url),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              alignment: widget.alignment,
              repeat: widget.repeat,
              placeholderBuilder: (context) => Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 50,
                  )
                ),
              ),
              errorBuilder: OctoError.placeholderWithErrorIcon((context) => Container(
                color: Colors.grey.shade800,
              ),
              iconSize: 0
              )
          ),
        ),
      ),
    );
  }
}

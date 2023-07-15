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
      child: Center(
        child: Hero(
          tag: widget.url + widget.width.toString() + widget.height.toString(),
          child: OctoImage(
            image: NetworkImage(widget.url),
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            alignment: widget.alignment,
            repeat: widget.repeat,
            placeholderBuilder: (context) => LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.onSurface,
              size: 50,
            ),
            errorBuilder: OctoError.blurHash(
              'LPOe[M{tZjj;KnPTowa#4=xtyBbJ',
              icon: null,
              iconColor: Colors.grey.shade800,
            )
          ),
        ),
      ),
    );
  }
}

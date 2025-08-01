import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Basic shimmer box used for placeholders.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer paragraph consisting of multiple lines.
class ShimmerParagraph extends StatelessWidget {
  final int lines;
  final double spacing;
  final double height;
  const ShimmerParagraph({
    super.key,
    this.lines = 2,
    this.spacing = 8,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : spacing),
          child: ShimmerBox(height: height, width: double.infinity),
        );
      }),
    );
  }
}

/// Simple list tile skeleton.
class ShimmerListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasSubtitle;
  final double leadingSize;
  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = false,
    this.leadingSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasLeading)
            ShimmerBox(
              height: leadingSize,
              width: leadingSize,
              shape: BoxShape.circle,
            ),
          if (hasLeading) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 22, width: double.infinity),
                if (hasSubtitle) ...[
                  const SizedBox(height: 8),
                  ShimmerBox(height: 16, width: double.infinity),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility widget to switch between skeleton and child.
class ShimmerLoading extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading ? skeleton : child;
  }
}

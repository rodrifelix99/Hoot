import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

class LikeButtonComponent extends StatefulWidget {
  final bool liked;
  final VoidCallback onTap;
  final double size;

  const LikeButtonComponent({
    super.key,
    required this.liked,
    required this.onTap,
    this.size = 20,
  });

  @override
  State<LikeButtonComponent> createState() => _LikeButtonComponentState();
}

class _LikeButtonComponentState extends State<LikeButtonComponent>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.liked) {
      _rotationController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant LikeButtonComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liked != oldWidget.liked) {
      if (widget.liked) {
        _rotationController.forward(from: 0);
        _heartController.forward(from: 0);
      } else {
        _rotationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.liked
        ? Colors.red
        : Theme.of(context).iconTheme.color;
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size + 20,
        height: widget.size + 20,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                final angle = _rotationController.value * math.pi;
                final showAsset = _rotationController.value > 0.5;
                Widget icon;
                if (showAsset) {
                  icon = Image.asset(
                    'assets/images/heart.png',
                    width: widget.size,
                    height: widget.size,
                    color: Colors.red,
                  );
                } else {
                  icon = Icon(
                    widget.liked
                        ? SolarIconsBold.heart
                        : SolarIconsOutline.heart,
                    color: iconColor,
                    size: widget.size,
                  );
                }
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(angle),
                  child: icon,
                );
              },
            ),
            AnimatedBuilder(
              animation: _heartController,
              child: Icon(
                SolarIconsBold.heart,
                color: Colors.red,
                size: widget.size * 0.7,
              ),
              builder: (context, child) {
                if (_heartController.status == AnimationStatus.dismissed) {
                  return const SizedBox.shrink();
                }
                final dy = -20 * _heartController.value;
                final opacity = 1 - _heartController.value;
                return Positioned(
                  top: dy,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

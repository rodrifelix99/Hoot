import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/util/enums/feed_types.dart';
import 'package:hoot/components/shimmer_skeletons.dart';

class TypeBoxComponent extends StatefulWidget {
  final FeedType type;
  final bool isLast;
  final bool isSkeleton;

  const TypeBoxComponent({
    super.key,
    required this.type,
    this.isLast = false,
    this.isSkeleton = false,
  });

  @override
  State<TypeBoxComponent> createState() => _TypeBoxComponentState();
}

class _TypeBoxComponentState extends State<TypeBoxComponent> {
  late Color color;

  @override
  void initState() {
    color = Colors.primaries[widget.type.index % Colors.primaries.length % 18];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.6),
        color.withValues(alpha: 0.9),
      ],
    );

    final bubbleSkeleton = Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
      ),
    );

    final bubble = Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.only(bottom: 32, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -25,
            child: Icon(
              widget.isLast
                  ? Icons.more_vert_rounded
                  : FeedTypeExtension.toIcon(widget.type),
              color: Colors.white.withValues(alpha: 0.2),
              size: 150,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            left: 16,
            child: SizedBox(
              child: Text(
                widget.isLast
                    ? 'discoverMoreFeeds'.tr
                    : FeedTypeExtension.toTranslatedString(
                        context, widget.type),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
        ],
      ),
    );

    final bubbleTailMiddle = Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
    );

    final bubbleTail = Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
    );

    return widget.isSkeleton
        ? ShimmerLoading(
            isLoading: widget.isSkeleton,
            skeleton: bubbleSkeleton,
            child: const SizedBox(),
          )
        : Stack(
            clipBehavior: Clip.none,
            children: [
              bubble,
              bubbleTailMiddle,
              bubbleTail,
            ],
          );
  }
}

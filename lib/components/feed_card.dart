import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/haptic_service.dart';

class FeedCard extends StatelessWidget {
  final Feed feed;
  final VoidCallback onTap;

  const FeedCard({
    super.key,
    required this.feed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = HashCachedImage(
      imageUrl: feed.bigAvatar ?? '',
      hash: feed.bigAvatarHash,
      errorWidget: (context, object, _) => Image.asset(
        'assets/images/bottom_bar_blue.jpg',
        fit: BoxFit.cover,
      ),
      fit: BoxFit.cover,
    );

    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // clear image underneath
              image,

              // blurred image on bottom half via vertical ShaderMask
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        // top: fully transparent mask → show clear image
                        Colors.transparent,
                        // bottom: fully opaque mask → show blurred image
                        Colors.black,
                      ],
                      // fade from 50% to 70% of height
                      stops: [0.5, 0.7],
                    ).createShader(rect);
                  },
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: image,
                  ),
                ),
              ),

              // optional dark gradient overlay to boost text contrast
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),

              // text content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (feed.description?.isNotEmpty == true
                          ? feed.description!
                          : '${feed.subscriberCount ?? 0} ${'followers'.tr}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

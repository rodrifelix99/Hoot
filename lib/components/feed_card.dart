import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:blur/blur.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/services/haptic_service.dart';

class FeedCard extends StatelessWidget {
  final Feed feed;
  final void Function() onTap;

  const FeedCard({
    super.key,
    required this.feed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String content = feed.description ?? '';
    if (content.isEmpty) {
      content = '${feed.subscriberCount ?? 0} ${'followers'.tr}';
    }
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              HashCachedImage(
                imageUrl: feed.bigAvatar ?? '',
                hash: feed.bigAvatarHash,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 64,
                left: 0,
                right: 0,
                bottom: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 8),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return Blur(
                      blur: value,
                      blurColor: Colors.black,
                      colorOpacity: 0.3,
                      overlay: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
                      child: const SizedBox.shrink(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
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

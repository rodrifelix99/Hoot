import 'package:flutter/material.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black12,
                      Colors.black87,
                    ],
                  ),
                ),
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
                      feed.description ?? feed.subscriberCount.toString(),
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

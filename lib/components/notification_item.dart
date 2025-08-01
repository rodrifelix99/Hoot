import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:hoot/components/scale_on_press.dart';
import 'package:hoot/components/avatar_component.dart';

class NotificationItem extends StatelessWidget {
  final String avatarUrl;
  final String? avatarHash;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;
  final Widget? trailing;

  const NotificationItem({
    super.key,
    required this.avatarUrl,
    this.avatarHash,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onAvatarTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(75),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileAvatarComponent(
                image: avatarUrl,
                hash: avatarHash,
                size: 60,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

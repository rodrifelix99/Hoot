import 'package:flutter/material.dart';

import 'package:hoot/components/scale_on_press.dart';
import 'package:hoot/components/avatar_component.dart';

class ListItem extends StatelessWidget {
  final String avatarUrl;
  final String? avatarHash;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;
  final Widget? trailing;

  const ListItem({
    super.key,
    required this.avatarUrl,
    this.avatarHash,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onAvatarTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              size: 50,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
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

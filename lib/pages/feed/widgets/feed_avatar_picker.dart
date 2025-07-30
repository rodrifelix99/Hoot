import 'dart:io';

import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/services/haptic_service.dart';

import '../../../components/avatar_component.dart';

class FeedAvatarPicker extends StatelessWidget {
  final File? file;
  final String? imageUrl;
  final VoidCallback onTap;
  final Color? color;
  final Color? foregroundColor;

  const FeedAvatarPicker({
    super.key,
    required this.file,
    this.imageUrl,
    required this.onTap,
    this.color,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        file != null || (imageUrl != null && imageUrl!.isNotEmpty);
    Widget avatarWidget;
    if (file != null) {
      avatarWidget = ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.file(
          file!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarWidget = ProfileAvatarComponent(
        image: imageUrl!,
        size: 120,
        radius: 32,
        color: color,
        foregroundColor: foregroundColor,
      );
    } else {
      avatarWidget = ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          'assets/images/avatar.png',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            avatarWidget,
            if (hasAvatar)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Icon(
                      SolarIconsBold.cameraAdd,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

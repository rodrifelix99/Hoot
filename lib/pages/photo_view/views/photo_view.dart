import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/pages/photo_view/controllers/photo_view_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:hoot/services/haptic_service.dart';

class PhotoZoomView extends GetView<PhotoZoomViewController> {
  const PhotoZoomView({super.key});

  ImageProvider get provider {
    final imageUrl = controller.imageUrl;
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }
    if (imageUrl.startsWith('data:')) {
      final base64Data = imageUrl.split(',').last;
      return MemoryImage(base64Decode(base64Data));
    }
    if (_isBase64(imageUrl)) {
      return MemoryImage(base64Decode(imageUrl));
    }
    return AssetImage(imageUrl);
  }

  bool _isBase64(String str) {
    final regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    if (str.length % 4 != 0 || !regex.hasMatch(str)) {
      return false;
    }
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          HapticService.lightImpact();
          Navigator.pop(context);
        },
        child: PhotoView(
          heroAttributes: PhotoViewHeroAttributes(tag: controller.imageUrl),
          imageProvider: provider,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}

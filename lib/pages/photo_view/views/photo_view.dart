import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/pages/photo_view/controllers/photo_view_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:hoot/util/image_utils.dart';

class PhotoZoomView extends GetView<PhotoZoomViewController> {
  const PhotoZoomView({super.key});

  ImageProvider get provider {
    final imageUrl = controller.imageUrl;
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }
    if (isBase64ImageData(imageUrl)) {
      return MemoryImage(decodeBase64Image(imageUrl));
    }
    return AssetImage(imageUrl);
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hoot/components/image_component.dart';

class PostMediaPreview extends StatelessWidget {
  final List<File> imageFiles;
  final String? gifUrl;
  final void Function(String path) onOpenViewer;
  final void Function(int index) onRemoveImage;
  final VoidCallback onRemoveGif;

  const PostMediaPreview({
    super.key,
    required this.imageFiles,
    required this.gifUrl,
    required this.onOpenViewer,
    required this.onRemoveImage,
    required this.onRemoveGif,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFiles.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageFiles.length,
          itemBuilder: (context, i) {
            final file = imageFiles[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => onOpenViewer(file.path),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(i),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else if (gifUrl != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            children: [
              ImageComponent(
                url: gifUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                radius: 8,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemoveGif,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

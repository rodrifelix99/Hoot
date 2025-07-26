import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:photo_view/photo_view.dart';
import '../controllers/create_post_controller.dart';
import '../../../components/url_preview_component.dart';
import '../../../models/feed.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({super.key});

  void _openViewer(BuildContext context, ImageProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PhotoView(
              imageProvider: provider,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickGif(BuildContext context) async {
    final tenor = await TenorGifPickerPage.openAsPage(
      context,
    );
    if (tenor != null) {
      controller.pickGif(tenor.mediaFormats['gif']?.url ??
          tenor.mediaFormats.values.first.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'createPost'.tr,
        actions: [
          Obx(() => controller.publishing.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: controller.publish,
                  child: Text('publish'.tr),
                ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.textController,
              maxLength: 280,
              minLines: 3,
              maxLines: null,
              decoration: InputDecoration(hintText: 'createPost'.tr),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.imageFiles.isNotEmpty) {
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.imageFiles.length,
                    itemBuilder: (context, i) {
                      final file = controller.imageFiles[i];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _openViewer(context, FileImage(file)),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
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
                              onTap: () => controller.removeImage(i),
                              child: Container(
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
                      );
                    },
                  ),
                );
              } else if (controller.gifUrl.value != null) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _openViewer(
                          context, NetworkImage(controller.gifUrl.value!)),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(controller.gifUrl.value!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.gifUrl.value = null,
                        child: Container(
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
                );
              }
              return const SizedBox.shrink();
            }),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: controller.pickImage,
                  tooltip: 'addImage'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.gif_box),
                  onPressed: () => pickGif(context),
                  tooltip: 'addGif'.tr,
                ),
              ],
            ),
            Builder(builder: (_) {
              final url = controller.linkUrl;
              if (url != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: UrlPreviewComponent(url: url, isClickable: false),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),
            Obx(() {
              return DropdownButton<Feed>(
                value: controller.selectedFeed.value,
                hint: Text('selectFeed'.tr),
                onChanged: (f) => controller.selectedFeed.value = f,
                isExpanded: true,
                items: controller.availableFeeds
                    .map((feed) => DropdownMenuItem(
                          value: feed,
                          child: Text(feed.title),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

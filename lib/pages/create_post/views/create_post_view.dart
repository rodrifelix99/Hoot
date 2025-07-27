import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/post_media_preview.dart';
import 'package:hoot/components/mention_text_field.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import '../controllers/create_post_controller.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:hoot/models/feed.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({super.key});

  void _openViewer(String url) {
    Get.toNamed(
      AppRoutes.photoViewer,
      arguments: {'imageUrl': url},
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
                  onPressed: () async {
                    final post = await controller.publish();
                    if (post != null) {
                      Get.toNamed(AppRoutes.post, arguments: post);
                    }
                  },
                  child: Text('publish'.tr),
                ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              return DropdownButton2<Feed>(
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
            const SizedBox(height: 8),
            MentionTextField(
              mentionKey: controller.mentionKey,
              suggestions: controller.mentionSuggestions,
              maxLength: 280,
              minLines: 5,
              maxLines: 10,
              hintText: 'postPlaceholder'.tr,
              onSearchChanged: controller.searchUsers,
              onChanged: (v) => controller.textController.text = v,
            ),
            const SizedBox(height: 16),
            Obx(() => PostMediaPreview(
                  imageFiles: controller.imageFiles,
                  gifUrl: controller.gifUrl.value,
                  onOpenViewer: _openViewer,
                  onRemoveImage: controller.removeImage,
                  onCropImage: controller.cropImage,
                  onRemoveGif: () => controller.gifUrl.value = null,
                )),
            Obx(() {
              final disableImages = controller.gifUrl.value != null ||
                  controller.imageFiles.length >= 4;
              final disableGif = controller.imageFiles.isNotEmpty;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(SolarIconsBold.gallery),
                    onPressed: disableImages ? null : controller.pickImage,
                    tooltip: 'addImage'.tr,
                  ),
                  IconButton(
                    icon: const Icon(Icons.gif_box_rounded),
                    onPressed: disableGif ? null : () => pickGif(context),
                    tooltip: 'addGif'.tr,
                  ),
                ],
              );
            }),
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
          ],
        ),
      ),
    );
  }
}

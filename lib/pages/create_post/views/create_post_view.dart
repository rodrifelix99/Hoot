import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/create_post_controller.dart';
import '../../../components/url_preview_component.dart';
import '../../../models/feed.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({super.key});

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
              maxLines: null,
              decoration:
                  InputDecoration(hintText: 'createPost'.tr),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.imageFile.value != null) {
                return Image.file(controller.imageFile.value!);
              } else if (controller.gifUrl.value != null) {
                return Image.network(controller.gifUrl.value!);
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
                  onPressed: () => controller.pickGif(context),
                  tooltip: 'addGif'.tr,
                ),
              ],
            ),
            Obx(() {
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

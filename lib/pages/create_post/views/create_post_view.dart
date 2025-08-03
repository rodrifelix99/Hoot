import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/post_media_preview.dart';
import 'package:hoot/components/mention_text_field.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/pages/home/controllers/home_controller.dart';
import 'package:hoot/pages/feed/controllers/feed_controller.dart';

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
      ),
      body: Obx(() {
        int feedCount = controller.availableFeeds.length;
        if (feedCount == 0) {
          return Center(
            child: NothingToShowComponent(
              imageAsset: 'assets/images/image_8.png',
              title: 'createFeedFirstTitle'.tr,
              text: 'createFeedFirstDescription'.tr,
              buttonText: 'createFeed'.tr,
              buttonAction: () => Get.toNamed(AppRoutes.createFeed),
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonHideUnderline(
                    child: Obx(() {
                      final selected = controller.selectedFeeds;
                      return DropdownButton2<Feed>(
                        isExpanded: true,
                        hint: Text('selectFeed'.tr),
                        items: controller.availableFeeds
                            .map((feed) => DropdownMenuItem<Feed>(
                                  value: feed,
                                  enabled: false,
                                  child: StatefulBuilder(
                                    builder: (context, menuSetState) {
                                      final isSelected =
                                          selected.contains(feed);
                                      return InkWell(
                                        onTap: () {
                                          isSelected
                                              ? selected.remove(feed)
                                              : selected.add(feed);
                                          selected.refresh();
                                          menuSetState(() {});
                                        },
                                        child: Container(
                                          height: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              if (isSelected)
                                                const Icon(
                                                    Icons.check_box_outlined)
                                              else
                                                const Icon(Icons
                                                    .check_box_outline_blank),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  feed.title,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ))
                            .toList(),
                        value: selected.isEmpty ? null : selected.last,
                        onChanged: (_) {},
                        selectedItemBuilder: (context) {
                          return controller.availableFeeds.map((feed) {
                            return Container(
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                selected.map((f) => f.title).join(', '),
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            );
                          }).toList();
                        },
                        dropdownStyleData: DropdownStyleData(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .inputDecorationTheme
                                .fillColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  MentionTextField(
                    mentionKey: controller.mentionKey,
                    suggestions: controller.mentionSuggestions,
                    maxLength: 280,
                    minLines: 5,
                    maxLines: 10,
                    hintText: 'postPlaceholder'.tr,
                    onSearchChanged: controller.searchUsers,
                    onChanged: controller.onTextChanged,
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
                          onPressed:
                              disableImages ? null : controller.pickImage,
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
                  Obx(() {
                    final url = controller.linkUrl.value;
                    if (url != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child:
                            UrlPreviewComponent(url: url, isClickable: false),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Hero(
                tag: 'createHootButton',
                child: Obx(() {
                  final loading = controller.publishing.value;
                  if (loading) {
                    return Center(
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () async {
                      final post = await controller.publish();
                      if (post != null) {
                        // Return to the feed after publishing
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().changeIndex(0);
                        }
                        if (Get.isRegistered<FeedController>()) {
                          Get.find<FeedController>().refresh();
                        }
                        Get.back();
                      }
                    },
                    child: Text('publish'.tr),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}

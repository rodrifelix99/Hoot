import 'package:animate_do/animate_do.dart';
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
import 'package:hoot/util/enums/feed_types.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String _getTrendingTitle(BuildContext context) {
    final feed = controller.selectedFeeds.isNotEmpty
        ? controller.selectedFeeds.last
        : null;
    final type = feed?.type;
    if (type?.rssTopic != null) {
      final translatedType =
          FeedTypeExtension.toTranslatedString(context, type!);
      return 'trendingIn'.trParams({'topic': translatedType});
    }
    return 'trendingNews'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final prefill = Get.parameters['text'];
    if (prefill != null && controller.textController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final text = Uri.decodeComponent(prefill);
        controller.mentionKey.currentState?.controller?.text = text;
        controller.onTextChanged(text);
      });
    }
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
                                      return GestureDetector(
                                        onTap: () {
                                          isSelected
                                              ? selected.remove(feed)
                                              : selected.add(feed);
                                          selected.refresh();
                                          menuSetState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            if (isSelected)
                                              const Icon(
                                                  SolarIconsBold.checkSquare)
                                            else
                                              const Icon(
                                                  SolarIconsOutline.addSquare),
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
                              alignment: AlignmentDirectional.centerStart,
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
                        IconButton(
                          icon: controller.location.value == null
                              ? Icon(SolarIconsOutline.gps)
                              : Icon(SolarIconsBold.gps),
                          onPressed: controller.toggleLocation,
                          tooltip: controller.location.value == null
                              ? 'addLocation'.tr
                              : 'removeLocation'.tr,
                        ),
                        if (controller.location.value != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              controller.location.value!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    );
                  }),
                  Obx(() {
                    final news = controller.trendingNews.take(5).toList();
                    if (news.isEmpty) return const SizedBox.shrink();
                    return FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).shadowColor.withAlpha(10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: news.length,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Theme.of(context).dividerColor.withAlpha(25),
                          ),
                          itemBuilder: (context, index) {
                            final n = news[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ).copyWith(
                                      bottom: 0,
                                    ),
                                    child: Text(
                                      _getTrendingTitle(context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                ListTile(
                                  onTap: () => launchUrl(Uri.parse(n.link)),
                                  leading: Opacity(
                                    opacity: 0.75,
                                    child: const Icon(SolarIconsBold.graphUp),
                                  ),
                                  title: Text(
                                    n.title,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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

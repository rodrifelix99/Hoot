import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/feed_editor/controllers/feed_editor_controller.dart';
import 'package:hoot/util/extensions/feed_extension.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/pages/feed/widgets/feed_form.dart';
import 'package:hoot/pages/feed/widgets/feed_avatar_picker.dart';

/// A unified view for creating and editing feeds using [FeedEditorController].
class FeedEditorView extends StatelessWidget {
  const FeedEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeedEditorController>();
    final isEditing = controller.feed != null;

    return Scaffold(
      appBar: AppBarComponent(
        title: isEditing ? 'editFeed'.tr : 'createFeed'.tr,
        actions: [
          Obx(
            () => controller.submitting.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: () async {
                      final result = await controller.submit();
                      if (result) Get.back();
                    },
                    icon: const Icon(SolarIconsBold.checkSquare),
                    iconSize: 32,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => Center(
                  child: FeedAvatarPicker(
                    file: controller.avatarFile.value,
                    imageUrl: controller.feed?.bigAvatar ??
                        controller.feed?.smallAvatar,
                    hash: controller.feed?.bigAvatarHash ??
                        controller.feed?.smallAvatarHash,
                    color: controller.feed?.color,
                    foregroundColor: controller.feed?.foregroundColor,
                    onTap: controller.pickAvatar,
                  ),
                )),
            const SizedBox(height: 16),
            FeedForm(
              titleController: controller.titleController,
              descriptionController: controller.descriptionController,
              typeSearchController: controller.typeSearchController,
              selectedColor: controller.selectedColor,
              onColorChanged: (c) => controller.selectedColor.value = c,
              selectedType: controller.selectedType,
              onTypeChanged: (t) => controller.selectedType.value = t,
              isPrivate: controller.isPrivate,
              onPrivateChanged: (v) => controller.isPrivate.value = v,
              isNsfw: controller.isNsfw,
              onNsfwChanged: (v) => controller.isNsfw.value = v,
              allowExternalHoots: controller.allowExternalHoots,
              onAllowExternalChanged: (v) =>
                  controller.allowExternalHoots.value = v,
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              Obx(() => controller.deleting.value
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      onPressed: () async {
                        final result = await controller.deleteFeed(context);
                        if (result) Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Text('deleteFeed'.tr),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}

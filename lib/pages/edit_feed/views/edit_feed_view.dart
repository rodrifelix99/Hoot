import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/edit_feed_controller.dart';
import '../../feed/widgets/feed_form.dart';

class EditFeedView extends GetView<EditFeedController> {
  const EditFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'editFeed'.tr,
        actions: [
          Obx(
            () => controller.saving.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(
                    onPressed: () async {
                      final result = await controller.save();
                      if (result) Get.back();
                    },
                    child: Text('done'.tr),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ),
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
        ),
      ),
    );
  }
}

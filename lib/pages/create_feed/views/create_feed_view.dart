import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/create_feed_controller.dart';
import '../../feed/widgets/feed_form.dart';

class CreateFeedView extends GetView<CreateFeedController> {
  const CreateFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'createFeed'.tr,
        actions: [
          Obx(
            () => controller.creating.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(
                    onPressed: () async {
                      final result = await controller.createFeed();
                      if (result) Get.back();
                    },
                    child: Text('done'.tr),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FeedForm(
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
      ),
    );
  }
}

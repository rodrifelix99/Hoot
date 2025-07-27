
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/image_component.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'editProfile'.tr,
        actions: [
          Obx(() => controller.saving.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: () async {
                    final result = await controller.saveProfile();
                    if (result) Get.back();
                  },
                  child: Text('done'.tr),
                ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final file = controller.bannerFile.value;
              final user = controller.user;
              Widget imageWidget;
              if (file != null) {
                imageWidget = Image.file(file, fit: BoxFit.cover);
              } else if (user?.bannerPictureUrl != null &&
                  user!.bannerPictureUrl!.isNotEmpty) {
                imageWidget = ImageComponent(
                  url: user.bannerPictureUrl!,
                  fit: BoxFit.cover,
                  height: 120,
                  width: double.infinity,
                );
              } else {
                imageWidget = Container(
                  height: 120,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.photo,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                );
              }
              return GestureDetector(
                onTap: controller.pickBanner,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(height: 120, child: imageWidget),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(labelText: 'displayName'.tr),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bioController,
              decoration: InputDecoration(labelText: 'bio'.tr),
              maxLines: 3,
              maxLength: 160,
            ),
          ],
        ),
      ),
    );
  }
}

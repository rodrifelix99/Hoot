import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:hoot/pages/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final bannerFile = controller.bannerFile.value;
      final avatarFile = controller.avatarFile.value;
      final user = controller.user;

      Widget bannerWidget;
      final hasBanner = bannerFile != null ||
          (user?.bannerPictureUrl != null &&
              user!.bannerPictureUrl!.isNotEmpty);
      if (bannerFile != null) {
        bannerWidget = Image.file(
          bannerFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        );
      } else if (user?.bannerPictureUrl != null &&
          user!.bannerPictureUrl!.isNotEmpty) {
        bannerWidget = ImageComponent(
          url: user.bannerPictureUrl!,
          hash: user.bannerHash,
          fit: BoxFit.cover,
          height: 300,
          width: double.infinity,
          radius: 16,
        );
      } else {
        bannerWidget = Container(
          height: 300,
          width: double.infinity,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.photo,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        );
      }

      Widget avatarWidget;
      final hasAvatar = avatarFile != null ||
          (user?.largeProfilePictureUrl != null &&
              user!.largeProfilePictureUrl!.isNotEmpty);
      if (avatarFile != null) {
        avatarWidget = ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(
            avatarFile,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      } else {
        avatarWidget = ProfileAvatarComponent(
          image: user?.largeProfilePictureUrl ?? '',
          hash: user?.bigAvatarHash ?? user?.smallAvatarHash,
          size: 120,
        );
      }

      return SizedBox(
        height: 400,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                HapticService.lightImpact();
                controller.pickBanner();
              },
              child: Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: bannerWidget,
                  ),
                  if (hasBanner)
                    Positioned.fill(
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            SolarIconsBold.cameraAdd,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 264,
              left: 16,
              right: 16,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticService.lightImpact();
                    controller.pickAvatar();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        avatarWidget,
                        if (hasAvatar)
                          Positioned.fill(
                            child: Container(
                              decoration: ShapeDecoration(
                                color: Colors.black26,
                                shape: CircleBorder(),
                              ),
                              child: const Center(
                                child: Icon(
                                  SolarIconsBold.cameraAdd,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'editProfile'.tr,
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
                : IconButton(
                    onPressed: () async {
                      final result = await controller.saveProfile();
                      if (result) Get.back();
                    },
                    icon: Icon(SolarIconsBold.checkSquare),
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
            _buildHeader(context),
            const SizedBox(height: 16),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(labelText: 'displayName'.tr),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bioController,
              decoration: InputDecoration(labelText: 'bio'.tr),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              maxLength: 160,
            ),
          ],
        ),
      ),
    );
  }
}

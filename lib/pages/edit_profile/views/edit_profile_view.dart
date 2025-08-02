
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/services/haptic_service.dart';
import 'package:hoot/pages/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final bannerFile = controller.avatarFile.value;
      final user = controller.user;
      final hasBanner = bannerFile != null ||
          (user?.bannerPictureUrl != null &&
              user!.bannerPictureUrl!.isNotEmpty);

      return GestureDetector(
        onTap: () {
          HapticService.lightImpact();
          controller.pickAvatar();
        },
        child: AspectRatio(
          aspectRatio: 0.7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (bannerFile != null)
                Image.file(
                  bannerFile,
                  fit: BoxFit.cover,
                )
              else if (user?.bannerPictureUrl != null &&
                  user!.bannerPictureUrl!.isNotEmpty)
                IgnorePointer(
                  child: ImageComponent(
                    url: user.bannerPictureUrl!,
                    hash: user.bannerHash,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 500,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Center(
                    child: Icon(
                      SolarIconsBold.cameraAdd,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(top: 150, bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withAlpha(0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller.nameController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 50,
                        decoration: InputDecoration(
                          hintText: 'displayName'.tr,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasBanner)
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        SolarIconsBold.cameraAdd,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'editProfile'.tr,
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
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
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0).copyWith(top: 0),
                child: TextField(
                  controller: controller.bioController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  maxLength: 160,
                  decoration: InputDecoration(
                    hintText: 'bio'.tr,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

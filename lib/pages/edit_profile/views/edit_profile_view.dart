import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
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
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32)
                      .copyWith(top: 150),
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
                      Glassify(
                        settings: LiquidGlassSettings(
                          blur: 16,
                          glassColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.white38,
                        ),
                        child: TextField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'displayName'.tr,
                            counterText: '',
                          ),
                          style: Get.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 64,
                          ),
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 50,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${user?.username ?? ''}',
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: TextField(
                          controller: controller.bioController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'bio'.tr,
                            counterText: '',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          maxLength: 160,
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
        child: _buildHeader(context),
      ),
    );
  }
}

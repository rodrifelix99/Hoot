import 'package:animate_do/animate_do.dart';
import 'package:hash_cached_image/hash_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hoot/pages/invitation/controllers/invitation_controller.dart';

class InvitationView extends GetView<InvitationController> {
  const InvitationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 1000),
              child: HashCachedImage(
                imageUrl:
                    'https://r1.ilikewallpaper.net/ipad-pro-wallpapers/download/100031/dark-blur-abstract-4k-ipad-pro-wallpaper-ilikewallpaper_com.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 2500),
                      child: Text(
                        'welcome'.tr,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return FadeIn(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 3500),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: !controller.isCrossFade.value
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Text(
                            'invitationExclusiveCommunity'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          secondChild: Text(
                            'invitationCuratedExperience'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 4500),
                      child: Text(
                        'invitationAccessLimited'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 5000),
                      child: Opacity(
                        opacity: 0.8,
                        child: TextField(
                          controller: controller.codeController,
                          decoration:
                              InputDecoration(labelText: 'invitationCode'.tr),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 5500),
                        child: ElevatedButton(
                          onPressed: controller.verifying.value
                              ? null
                              : controller.verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: controller.verifying.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text('stepInside'.tr),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

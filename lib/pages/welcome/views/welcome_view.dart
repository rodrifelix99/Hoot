import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../avatar/controllers/avatar_controller.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final SwiperController _controller = SwiperController();

  late final AvatarController _avatarController;
  late final WelcomeController _welcomeController;

  @override
  void initState() {
    super.initState();
    _avatarController = Get.put(AvatarController());
    _welcomeController = Get.find<WelcomeController>();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'waitANewFriend'.tr,
      'letsSpiceItUp'.tr,
      'almostThere'.tr,
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/welcome_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/image_1.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_2.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_3.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_4.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_17.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_18.png",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/images/image_5.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_6.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_7.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_8.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_15.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_16.png",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/image_9.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_10.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_11.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_12.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_13.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_14.png",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.15),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: const Offset(0, -5), // changes position of shadow
                  ),
                ],
              ),
              child: Swiper(
                controller: _controller,
                index: widget.initialIndex,
                loop: false,
                itemCount: 3,
                itemBuilder: (context, i) {
                  switch (i) {
                    case 0:
                      return _buildCard(
                        titles[i],
                        'displayNameDescription'.tr,
                        () async {
                          if (await _welcomeController.saveDisplayName()) {
                            _controller.next();
                          }
                        },
                        input: TextField(
                          controller: _welcomeController.displayNameController,
                          decoration: InputDecoration(
                            labelText: 'displayName'.tr,
                            hintText: 'displayNameExample'.tr,
                          ),
                        ),
                      );
                    case 1:
                      return _buildCard(
                        titles[i],
                        'usernameDescription'.tr,
                        () async {
                          if (await _welcomeController.saveUsername()) {
                            _controller.next();
                          }
                        },
                        input: TextField(
                          controller: _welcomeController.usernameController,
                          decoration: InputDecoration(
                            labelText: 'username'.tr,
                            hintText: 'usernameExample'.tr,
                          ),
                        ),
                      );
                    default:
                      return _buildAvatarCard(titles[i]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String text,
    Future<void> Function() onPressed, {
    Widget? input,
    bool useSpacer = true,
  }) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            Text(text),
            if (input != null) ...[
              const SizedBox(height: 20),
              input,
            ],
            if (useSpacer) const Spacer(),
            ElevatedButton(
              onPressed: onPressed,
              child: Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(String title) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Obx(() {
          final file = _avatarController.avatarFile.value;
          final uploading = _avatarController.uploading.value;
          final message = _avatarController.avatarMessage.value;
          final buttonLabel =
              file == null ? 'skipForNow'.tr : 'continueButton'.tr;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 20),
              Text('profilePictureDescription'.tr),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _avatarController.pickAvatar,
                        child: CircleAvatar(
                          radius: 64,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage:
                              file != null ? FileImage(file) : null,
                          child: file == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(64),
                                  child: Image.asset(
                                    'assets/images/avatar.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: uploading ? 0.5 : 1,
                child: ElevatedButton(
                  onPressed:
                      uploading ? null : _avatarController.finishOnboarding,
                  child: uploading
                      ? LoadingAnimationWidget.threeArchedCircle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        )
                      : Text(buttonLabel),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

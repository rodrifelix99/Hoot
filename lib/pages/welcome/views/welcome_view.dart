import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../avatar/controllers/avatar_controller.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final SwiperController _controller = SwiperController();
  late int _index;

  late final AvatarController _avatarController;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _avatarController = Get.put(AvatarController());
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        .onBackground
                        .withOpacity(0.15),
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
                onIndexChanged: (i) => setState(() => _index = i),
                itemCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  switch (i) {
                    case 0:
                      return _buildCard(
                        titles[i],
                        'displayNameDescription'.tr,
                        () => _controller.next(),
                      );
                    case 1:
                      return _buildCard(
                        titles[i],
                        'usernameDescription'.tr,
                        () => _controller.next(),
                      );
                    default:
                      return _buildCard(
                        titles[i],
                        'profilePictureDescription'.tr,
                        _avatarController.finishOnboarding,
                      );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String text, VoidCallback onPressed) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const Spacer(),
            ElevatedButton(
              onPressed: onPressed,
              child: Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

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
      'whatsYourName'.tr,
      'letsSpiceItUp'.tr,
      'almostThere'.tr,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: Swiper(
        controller: _controller,
        index: widget.initialIndex,
        loop: false,
        onIndexChanged: (i) => setState(() => _index = i),
        itemCount: 3,
        pagination: const SwiperPagination(),
        itemBuilder: (context, i) {
          switch (i) {
            case 0:
              return _buildCard(
                'displayNameDescription'.tr,
                () => _controller.next(),
              );
            case 1:
              return _buildCard(
                'usernameDescription'.tr,
                () => _controller.next(),
              );
            default:
              return _buildCard(
                'profilePictureDescription'.tr,
                _avatarController.finishOnboarding,
              );
          }
        },
      ),
    );
  }

  Widget _buildCard(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            child: Text('continueButton'.tr),
          ),
        ],
      ),
    );
  }
}

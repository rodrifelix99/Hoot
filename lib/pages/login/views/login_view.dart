import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart' as buttons;
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:hoot/pages/login/controllers/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, this.playBackgroundVideo = true});

  final bool playBackgroundVideo;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.find();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.playBackgroundVideo) {
      _videoController =
          VideoPlayerController.asset('assets/videos/login_video.mp4')
            ..setLooping(false)
            ..initialize().then((_) {
              setState(() {});
              _videoController?.play();
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'welcomeDescription'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  buttons.SignInButton(
                    buttons.Buttons.Google,
                    onPressed: controller.signInWithGoogle,
                  ),
                  buttons.SignInButton(
                    buttons.Buttons.Apple,
                    onPressed: controller.signInWithApple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

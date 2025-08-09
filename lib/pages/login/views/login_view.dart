import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:video_player/video_player.dart';
import 'package:hoot/services/analytics_service.dart';

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
  AnalyticsService? _analytics;

  void _onVideoEvent() {
    final controller = _videoController;
    if (controller != null &&
        controller.value.position >= controller.value.duration &&
        !controller.value.isPlaying) {
      controller.removeListener(_onVideoEvent);
      _analytics?.logEvent('play_video_complete', parameters: {
        'screen': 'login',
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _analytics = Get.isRegistered<AnalyticsService>()
        ? Get.find<AnalyticsService>()
        : null;
    if (widget.playBackgroundVideo) {
      _videoController =
          VideoPlayerController.asset('assets/videos/login_video.mp4')
            ..setLooping(false)
            ..initialize().then((_) {
              setState(() {});
              _videoController?.addListener(_onVideoEvent);
              _videoController?.play();
              _analytics?.logEvent('play_video_start', parameters: {
                'screen': 'login',
              });
            });
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoEvent);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          Center(
            child: Glassify(
              settings: LiquidGlassSettings(
                blur: 10,
                glassColor: Colors.white38,
              ),
              child: Text(
                'appName'.tr,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 100,
                      fontWeight: FontWeight.w900,
                    ),
              ),
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
                  LiquidGlass(
                    shape: LiquidRoundedRectangle(
                      borderRadius: Radius.circular(32),
                    ),
                    settings: LiquidGlassSettings(
                      blur: 32,
                      glassColor: Colors.white12,
                    ),
                    glassContainsChild: false,
                    child: TextButton.icon(
                      onPressed: controller.signInWithGoogle,
                      label: Text('signInWithGoogle'.tr),
                      icon: const Icon(Icons.android_rounded),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LiquidGlass(
                    shape: LiquidRoundedRectangle(
                      borderRadius: Radius.circular(32),
                    ),
                    settings: LiquidGlassSettings(
                      blur: 32,
                      glassColor: Colors.white12,
                    ),
                    glassContainsChild: false,
                    child: TextButton.icon(
                      onPressed: controller.signInWithApple,
                      label: Text('signInWithApple'.tr),
                      icon: const Icon(Icons.apple_rounded),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                      children: [
                        TextSpan(text: '${'bySigningUpYouAgreeToOur'.tr} '),
                        TextSpan(
                          text: 'termsOfService'.tr,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(AppRoutes.terms);
                            },
                        ),
                      ],
                    ),
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

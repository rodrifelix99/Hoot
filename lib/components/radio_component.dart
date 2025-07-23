import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/radio_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RadioComponent extends StatefulWidget {
  const RadioComponent({super.key});

  @override
  State<RadioComponent> createState() => _RadioComponentState();
}

class _RadioComponentState extends State<RadioComponent> {
  late YoutubePlayerController controller;
  final RadioController radioController = Get.put(RadioController());

  final String _subscriber = 'osZWkRbk6jA';

  @override
  void initState() {
    controller = radioController.controller;
    super.initState();
    _listenForNotifications();
  }

  Future _listenForNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == "3") {
        controller.load(_subscriber);
        Future.delayed(const Duration(seconds: 17), () {
          controller.load(radioController.selectedKey.toString());
        });
      }
    });
  }

  void _pause() {
    radioController.pause();
  }

  void _play() {
    radioController.play();
  }

  String _imageUrl() {
    return radioController.imageUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // animated gradient
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.95),
            Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withValues(alpha: 0.95),
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      width: double.infinity,
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  radioController.loading.isTrue
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: LoadingAnimationWidget.waveDots(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              size: 25,
                            ),
                          ),
                        )
                      : !controller.value.isPlaying
                          ? IconButton(
                              icon: const Icon(Icons.play_arrow_rounded),
                              onPressed: () => _play(),
                            )
                          : IconButton(
                              icon: const Icon(Icons.stop_rounded),
                              onPressed: () => _pause(),
                            ),
                  radioController.showNext.isTrue
                      ? IconButton(
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () => radioController.next(),
                        )
                      : const SizedBox(),
                  Text(
                      radioController.songs[radioController.selectedKey.value]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(width: 5),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red, Colors.red.shade900],
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        child: Text('LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  YoutubePlayer(
                    controller: controller,
                    width: 0,
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: _imageUrl(),
                      placeholder: (context, url) => const SizedBox.shrink(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      fit: BoxFit.cover,
                      height: 50,
                      width: 75,
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/radio_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';

class RadioPage extends StatefulWidget {
  final Function closeRadio;
  const RadioPage({super.key, required this.closeRadio});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  final RadioController radioController = Get.put(RadioController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.of(context).pop(),
              widget.closeRadio()
            },
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                radioController.getMainColor()
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 50,
                  left: MediaQuery.of(context).size.width / 2 - 150,
                  right: MediaQuery.of(context).size.width / 2 - 150,
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Material(
                      elevation: radioController.loading.isFalse ? 10 : 0,
                      shadowColor: Colors.black.withOpacity(0.5),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: OctoImage(
                        image: NetworkImage(radioController.imageUrl()),
                        placeholderBuilder: OctoPlaceholder.blurHash(
                          'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                        ),
                        errorBuilder: OctoError.icon(color: Colors.red),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 50,
                    left: 10,
                    right: 10,
                    child: radioController.loading.isTrue ? Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: Colors.white,
                        size: 50,
                      ),
                    ) : Column(
                      children: [
                        Text(
                          radioController.songs[radioController.selectedKey.value]!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            'Live',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !radioController.controller.value.isPlaying ? IconButton(
                              icon: const Icon(Icons.play_arrow_rounded, size: 50),
                              color: Colors.white,
                              onPressed: () => radioController.play(),
                            ) : IconButton(
                              icon: const Icon(Icons.stop_rounded, size: 50),
                              color: Colors.white,
                              onPressed: () => radioController.pause(),
                            ),
                            radioController.showNext.isTrue ? IconButton(
                              icon: const Icon(Icons.skip_next_rounded, size: 50),
                              color: Colors.white,
                              onPressed: () => radioController.next(),
                            ) : const SizedBox(),
                          ],
                        ),
                      ],
                    )
                )
              ],
            ),
          )
      ),
      ),
    );
  }
}

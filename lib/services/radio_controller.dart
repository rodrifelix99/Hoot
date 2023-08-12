import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RadioController extends GetxController {
  var closeRadio = true.obs;
  var showNext = true.obs;
  var touched = false.obs;
  var loading = true.obs;
  var goingThroughNext = false.obs;
  final Map<String, String> songs = {
    'HQtFR3mhzOY': 'Pop Station',
    'rs9EPxiLz3o': 'Indie vibes',
    'Va-h6WZPUzQ': 'Rock Classics',
    'Vo-2noOnBcY': 'Lo-Fi Beats',
    'wXH_SkhhWds': 'Throwback Hits',
    'EurKD84TFtA': 'Best of Pop Rock',
    'N6ORdxoJH2Q': '2000\'s Hip Hop Hits',
    'lCjVa1c5zKw': 'Mind of Metal',
    'tSlOlKRuudU': 'Classical Hour',
  };
  final List<String> _voices = ['PKjDbuRuC9w', '3pFsWqKns4I', 'gJoLnvjS8Ro', 'rvX0cxK2OuI', 'PKjDbuRuC9w', '3pFsWqKns4I', 'gJoLnvjS8Ro', 'rvX0cxK2OuI'];
  var selectedKey = 'HQtFR3mhzOY'.obs;
  late YoutubePlayerController controller;

  @override
  void onInit() {
    selectedKey.value = songs.keys.first;
    controller = YoutubePlayerController(
      initialVideoId: songs.keys.first,
      flags: const YoutubePlayerFlags(
          startAt: 0,
          autoPlay: false,
          mute: false,
          showLiveFullscreenButton: false,
          forceHD: false,
          enableCaption: false,
          isLive: true,
          hideControls: true,
          hideThumbnail: true,
          controlsVisibleAtStart: false,
          disableDragSeek: true
      ),
    );
    super.onInit();
    _listenForControllerChanges();
  }

  Future _listenForControllerChanges() async {
    controller.addListener(() {
      loading.value = controller.value.playerState == PlayerState.buffering || controller.value.isReady == false;
      if (showNext.isFalse && controller.value.position.inSeconds == controller.value.metaData.duration.inSeconds && loading.isFalse && goingThroughNext.isFalse) {
        next();
      } else if (controller.value.isReady && !controller.value.isPlaying && touched.isFalse) {
        fadeIn();
      }
    });
  }

  Future fadeIn() async {
    touched.value = true;
    controller.play();
    if (showNext.isFalse) return;
    controller.setVolume(0);
    int i = 0;
    while (i < 100) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        controller.setVolume(i);
        i < 25 ? i++ : i += 5;
      });
    }
  }

  Future next() async {
    touched.value = false;
    goingThroughNext.value = true;
    showNext.value = !showNext.value;

    int index = songs.keys.toList().indexOf(selectedKey.value);
    if (showNext.isTrue) {
      controller.load(songs.keys.toList()[index]);
    } else {
      if (index == songs.length - 1) {
        index = 0;
      } else {
        index++;
      }
      selectedKey = songs.keys.toList()[index].obs;
      controller.load(_voices[Random().nextInt(_voices.length)]);
    }

    Future.delayed(const Duration(seconds: 1), () {
      goingThroughNext.value = false;
    });
  }

  void pause() {
    touched.value = true;
    controller.pause();
  }

  void play() {
    touched.value = true;
    controller.play();
  }

  String imageUrl() {
    switch (songs.values.toList()[songs.keys.toList().indexOf(selectedKey.value)].toLowerCase()) {
      case 'rock classics':
        return 'https://cdn.vox-cdn.com/thumbor/SpDYKjw5PmtvGmh2fRVG8v0I5Cg=/0x0:2000x1125/1200x675/filters:focal(840x403:1160x723):no_upscale()/cdn.vox-cdn.com/uploads/chorus_image/image/61516359/dazed_and_confused_music_1.0.gif';
      case 'pop station':
        return 'https://i.pinimg.com/originals/53/2c/26/532c261dd6bcafb9f3659ef79c676b74.gif';
      case 'throwback hits':
        return 'https://64.media.tumblr.com/b60f7d0e4d6efc91a83df36a925b8a03/tumblr_okavaqT6SL1siipepo1_500.gifv';
      case 'mind of metal':
        return 'https://images.squarespace-cdn.com/content/v1/542b4e6fe4b0d082dad4801a/1560392539470-LJ40XGTC7U3LG07GEA0U/loopingNoiseRaw.gif?format=1000w';
      case 'best of pop rock':
        return 'https://wallpapers.com/images/hd/pop-music-dq4x3sozgmiy23kc.jpg';
      case '2000\'s hip hop hits':
        return 'https://images.unsplash.com/photo-1513104487127-813ea879b8da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8aGlwJTIwaG9wfGVufDB8fDB8fHww&w=1000&q=80';
      case 'indie vibes':
        return 'https://64.media.tumblr.com/1b3e6a6d2d78d41e7cf344ee38b959ef/tumblr_inline_p23lwxxGPS1upaj4g_1280.gif';
      case 'classical hour':
        return 'https://static01.nyt.com/images/2019/04/18/arts/music/five-minutes-piano/five-minutes-piano-articleLarge.gif?quality=75&auto=webp&disable=upscale';
      case 'lo-fi beats':
        return 'https://i.redd.it/z4m6w0qlr3x91.gif';
      default:
        return 'https://cdn.myportfolio.com/03fb13c64084a4ecb1180901ecedad0d/091e6eb0-1a91-414c-b4fc-bc37d83daa89_rw_600.gif?h=e953dfb131b11a928d0f1f96d8c4e15d';
    }
  }

  Color getMainColor() {
    switch (songs.values.toList()[songs.keys.toList().indexOf(selectedKey.value)].toLowerCase()) {
      case 'rock classics':
        return Colors.blue;
      case 'pop station':
        return Colors.pink;
      case 'throwback hits':
        return Colors.yellow;
      case 'mind of metal':
        return Colors.grey;
      case 'best of pop rock':
        return Colors.purple;
      case '2000\'s hip hop hits':
        return Colors.orange;
      case 'indie vibes':
        return Colors.pinkAccent;
      case 'classical hour':
        return Colors.brown;
      case 'lo-fi beats':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
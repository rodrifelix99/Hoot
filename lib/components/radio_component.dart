import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RadioComponent extends StatefulWidget {
  const RadioComponent({super.key});

  @override
  State<RadioComponent> createState() => _RadioComponentState();
}

class _RadioComponentState extends State<RadioComponent> {
  bool _showNext = true;
  bool _touched = false;
  bool _loading = true;
  bool _goingThroughNext = false;
  final Map<String, String> _songs = {
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
  late String _selectedKey;
  late YoutubePlayerController controller;

  final String _feedAd = 'qDeVmQbXDkk';
  final String _subscriber = 'osZWkRbk6jA';

  @override
  void initState() {
    _selectedKey = _songs.keys.first;
    controller = YoutubePlayerController(
      initialVideoId: _songs.keys.first,
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
    super.initState();
    _listenForNotifications();
    _listenForControllerChanges();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _listenForNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == "3") {
        controller.load(_subscriber);
        Future.delayed(const Duration(seconds: 17), () {
          controller.load(_selectedKey);
        });
      }
    });
  }

  Future _listenForControllerChanges() async {
    controller.addListener(() {
      setState(() => _loading = controller.value.playerState == PlayerState.buffering || controller.value.isReady == false);
      if (!_showNext && controller.value.position.inSeconds == controller.value.metaData.duration.inSeconds && !_loading && !_goingThroughNext) {
        setState(() { _next(); });
      } else if (controller.value.isReady && !controller.value.isPlaying && !_touched) {
        _fadeIn();
      }
    });
  }

  Future _fadeIn() async {
    _touched = true;
    controller.play();
    if (!_showNext) return;
    controller.setVolume(0);
    int i = 0;
    while (i < 100) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        controller.setVolume(i);
        i < 25 ? i++ : i += 5;
      });
    }
  }

  Future _pause() async {
    _touched = true;
    controller.pause();
  }

  void _play() {
    _touched = true;
    controller.play();
  }

  Future _next() async {
    _touched = false;
    _goingThroughNext = true;
    setState(() => _showNext = !_showNext);

    int index = _songs.keys.toList().indexOf(_selectedKey);
    if (_showNext) {
      controller.load(_songs.keys.toList()[index]);
    } else {
      if (index == _songs.length - 1) {
        index = 0;
      } else {
        index++;
      }
      setState(() => _selectedKey = _songs.keys.toList()[index]);
      controller.load(_voices[Random().nextInt(_voices.length)]);
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _goingThroughNext = false);
    });
  }

  String _imageUrl() {
    switch (_songs.values.toList()[_songs.keys.toList().indexOf(_selectedKey)].toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // animated gradient
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.95),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _loading ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 25,
                  ),
                ),
              ) :
              !controller.value.isPlaying ? IconButton(
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: () => _play(),
              ) : IconButton(
                icon: const Icon(Icons.stop_rounded),
                onPressed: () => _pause(),
              ),
              _showNext ? IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: () => _next(),
              ) : const SizedBox(),
              Text(_songs[_selectedKey]!, style: const TextStyle(
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
                      colors: [
                        Colors.red,
                        Colors.red.shade900
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text('LIVE', style: TextStyle(
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
                child: OctoImage(
                  image: NetworkImage(_imageUrl()),
                  placeholderBuilder: OctoPlaceholder.blurHash(
                    'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                  ),
                  errorBuilder: OctoError.icon(color: Colors.red),
                  fit: BoxFit.cover,
                  height: 50,
                  width: 75,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

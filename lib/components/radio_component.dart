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
  final Map<String, String> _songs = {
    'Va-h6WZPUzQ': 'Rock Classics',
    'PKjDbuRuC9w': 'This is Hoot Radio',
    'HQtFR3mhzOY': 'Pop Station',
    '3pFsWqKns4I': 'This is Hoot Radio',
    'wXH_SkhhWds': 'Throwback Hits',
    'lCjVa1c5zKw': 'Mind of Metal',
    'gJoLnvjS8Ro': 'This is Hoot Radio',
    'EurKD84TFtA': 'Best of Pop Rock',
    'N6ORdxoJH2Q': '2000\'s Hip Hop Hits',
    'rvX0cxK2OuI': 'This is Hoot Radio',
  };
  late String _selectedKey;
  late YoutubePlayerController controller;

  String _feedAd = 'qDeVmQbXDkk';
  String _subscriber = 'osZWkRbk6jA';

  @override
  void initState() {
    _selectedKey = _songs.keys.first;
    controller = YoutubePlayerController(
      initialVideoId: _songs.keys.first,
      flags: const YoutubePlayerFlags(
        startAt: 0,
        autoPlay: true,
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
      setState(() {
        if (!_showNext && controller.value.position.inSeconds == controller.value.metaData.duration.inSeconds) {
          _next();
        } else if (controller.value.isReady && !controller.value.isPlaying && !_touched) {
          controller.play();
        }
      });
    });
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
    setState(() => _showNext = false);
    int index = _songs.keys.toList().indexOf(_selectedKey);
    if (index == _songs.length - 1) {
      index = 0;
    } else {
      index++;
    }
    setState(() => _selectedKey = _songs.keys.toList()[index]);
    controller.load(_songs.keys.toList()[index]);
    if (_songs.values.toList()[index] == 'This is Hoot Radio') {
      setState(() => _showNext = false);
    } else {
      setState(() => _showNext = true);
    }
  }

  String _imageUrl() {
    switch (_songs.values.toList()[_songs.keys.toList().indexOf(_selectedKey)]) {
      case 'Rock Classics':
        return 'https://rockradio.si/images/og-image.jpg';
      case 'Pop Station':
        return 'https://wallpapers.com/images/hd/pop-music-u8uxqgvwhv93s9a9.jpg';
      case 'Throwback Hits':
        return 'https://wallpapers.com/images/hd/80s-retro-arcade-music-734j2xcfqfk7espy.jpg';
      case 'Mind of Metal':
        return 'https://wallpapercave.com/wp/wp2709491.jpg';
      case 'Best of Pop Rock':
        return 'https://wallpapers.com/images/hd/pop-music-dq4x3sozgmiy23kc.jpg';
      case '2000\'s Hip Hop Hits':
        return 'https://images.unsplash.com/photo-1513104487127-813ea879b8da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8aGlwJTIwaG9wfGVufDB8fDB8fHww&w=1000&q=80';
      default:
        return 'https://radiodns.org/wp-content/themes/radiodns/assets/img/optimised/home/swash/x2/radiodns-swash@2x.jpg';
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
              !controller.value.isReady ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 25,
                  ),
                ),
              ) :
              !controller.value.isPlaying ? IconButton(
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: () => _play(),
              ) : IconButton(
                icon: const Icon(Icons.pause_rounded),
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
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Container(
                  color: Colors.red,
                  child: const Padding(
                    padding: EdgeInsets.all(5),
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

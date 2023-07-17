import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RadioComponent extends StatefulWidget {
  const RadioComponent({super.key});

  @override
  State<RadioComponent> createState() => _RadioComponentState();
}

class _RadioComponentState extends State<RadioComponent> {
  bool _paused = false;
  bool _showMedia = false;
  final Map<String, String> _songs = {
    'Va-h6WZPUzQ': 'Rock Classics',
    '3pFsWqKns4I': 'This is Hoot Radio',
    'HQtFR3mhzOY': 'Pop Station',
    'rvX0cxK2OuI': 'This is Hoot Radio',
    'wXH_SkhhWds': 'Throwback Hits',
    'PKjDbuRuC9w': 'This is Hoot Radio',
    'lCjVa1c5zKw': 'Mind of Metal',
    'gJoLnvjS8Ro': 'This is Hoot Radio',
  };
  late String _selectedKey;
  late YoutubePlayerController controller;

  @override
  void initState() {
    _selectedKey = _songs.keys.first;
    controller = YoutubePlayerController(
      initialVideoId: _songs.keys.first,
      flags: const YoutubePlayerFlags(
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
    _play();
  }

  Future _pause() async {
    controller.pause();
    setState(() => {
      _paused = true,
      _showMedia = false,
    });
  }

  void _play() {
    controller.play();
    setState(() => {
      _paused = false,
      _showMedia = true,
    });
  }

  Future _next() async {
    setState(() => _showMedia = false);
    int index = _songs.keys.toList().indexOf(_selectedKey);
    if (index == _songs.length - 1) {
      index = 0;
    } else {
      index++;
    }
    setState(() => _selectedKey = _songs.keys.toList()[index]);
    controller.load(_songs.keys.toList()[index]);
    _play();
    setState(() { });
    if (_songs.values.toList()[index] == 'This is Hoot Radio') {
      setState(() => _showMedia = false);
      Future.delayed(const Duration(seconds: 10), () {
        _next();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _paused ? IconButton(
                icon: const Icon(Icons.stream_rounded),
                onPressed: () => _play(),
              ) : IconButton(
                icon: const Icon(Icons.pause_rounded),
                onPressed: () => _pause(),
              ),
              _showMedia ? IconButton(
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
                  image: NetworkImage('https://cdn.wallpapersafari.com/13/6/tQDNaY.jpg'),
                  placeholderBuilder: OctoPlaceholder.blurHash(
                    'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                  ),
                  errorBuilder: OctoError.icon(color: Colors.red),
                  fit: BoxFit.cover,
                  height: 50,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

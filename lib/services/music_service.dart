import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'package:hoot/models/music_attachment.dart';
import 'package:hoot/services/analytics_service.dart';

abstract class BaseMusicService {
  Future<List<MusicAttachment>> searchSongs(String term);
}

class MusicService implements BaseMusicService {
  MusicService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  @override
  Future<List<MusicAttachment>> searchSongs(String term) async {
    final sw = Stopwatch()..start();
    try {
      final uri = Uri.https('itunes.apple.com', '/search', {
        'term': term,
        'entity': 'song',
      });
      final response = await _client.get(uri);
      final elapsed = sw.elapsedMilliseconds;
      if (response.statusCode != 200) {
        if (_analytics != null) {
          await _analytics!.logEvent('search_song', parameters: {
            'query': term,
            'resultCount': 0,
            'responseTimeMs': elapsed,
          });
        }
        return [];
      }
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> results = json['results'] as List<dynamic>? ?? [];
      final songs = results
          .whereType<Map<String, dynamic>>()
          .map(MusicAttachment.fromJson)
          .toList();
      if (_analytics != null) {
        await _analytics!.logEvent('search_song', parameters: {
          'query': term,
          'resultCount': songs.length,
          'responseTimeMs': elapsed,
        });
      }
      return songs;
    } catch (_) {
      if (_analytics != null) {
        await _analytics!.logEvent('search_song', parameters: {
          'query': term,
          'resultCount': 0,
          'responseTimeMs': sw.elapsedMilliseconds,
        });
      }
      return [];
    }
  }
}

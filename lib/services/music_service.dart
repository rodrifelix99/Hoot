import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:hoot/models/music_attachment.dart';

abstract class BaseMusicService {
  Future<List<MusicAttachment>> searchSongs(String term);
}

class MusicService implements BaseMusicService {
  MusicService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<MusicAttachment>> searchSongs(String term) async {
    try {
      final uri = Uri.https('itunes.apple.com', '/search', {
        'term': term,
        'entity': 'song',
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return [];
      }
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> results = json['results'] as List<dynamic>? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(MusicAttachment.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hoot/services/news_service.dart';
import 'package:hoot/services/language_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('constructs url from locale', () async {
    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response('<rss><channel></channel></rss>', 200);
    });
    final language = LanguageService();
    language.locale.value = const Locale('en', 'US');
    final service = NewsService(client: client, languageService: language);
    await service.fetchTrendingNews();
    expect(
        requested,
        Uri.https('news.google.com', '/rss',
            {'hl': 'en-US', 'gl': 'US', 'ceid': 'US:en'}));
  });

  test('uses topic path when topic is provided', () async {
    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response('<rss><channel></channel></rss>', 200);
    });
    final language = LanguageService();
    language.locale.value = const Locale('en', 'US');
    final service = NewsService(client: client, languageService: language);
    await service.fetchTrendingNews(topic: 'TECHNOLOGY');
    expect(
        requested,
        Uri.https('news.google.com', '/rss/headlines/section/topic/TECHNOLOGY',
            {'hl': 'en-US', 'gl': 'US', 'ceid': 'US:en'}));
  });

  test('adds locale parameters for topic requests', () async {
    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response('<rss><channel></channel></rss>', 200);
    });
    final language = LanguageService();
    language.locale.value = const Locale('es', 'MX');
    final service = NewsService(client: client, languageService: language);
    await service.fetchTrendingNews(topic: 'WORLD');
    expect(
        requested,
        Uri.https('news.google.com', '/rss/headlines/section/topic/WORLD',
            {'hl': 'es-MX', 'gl': 'MX', 'ceid': 'MX:es'}));
  });

  test('parses feed items', () async {
    const rss =
        '<rss version="2.0"><channel><item><title>Title 1</title><link>https://example.com/1</link></item></channel></rss>';
    final client = MockClient((request) async => http.Response(rss, 200));
    final language = LanguageService();
    final service = NewsService(client: client, languageService: language);
    final items = await service.fetchTrendingNews();
    expect(items.length, 1);
    expect(items.first.title, 'Title 1');
    expect(items.first.link, 'https://example.com/1');
  });
}

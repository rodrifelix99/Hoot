import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';

import 'language_service.dart';

/// Lightweight representation of a news article.
class NewsItem {
  NewsItem({required this.title, required this.link});
  final String title;
  final String link;
}

/// API definition for fetching news.
abstract class BaseNewsService {
  Future<List<NewsItem>> fetchTrendingNews({String? topic});
}

/// Default implementation downloading and parsing Google News RSS feeds.
class NewsService implements BaseNewsService {
  final http.Client _client;
  final LanguageService _languageService;

  NewsService({http.Client? client, LanguageService? languageService})
      : _client = client ?? http.Client(),
        _languageService = languageService ?? Get.find<LanguageService>();

  @override
  Future<List<NewsItem>> fetchTrendingNews({String? topic}) async {
    try {
      final locale = _languageService.locale.value;
      final lang = locale.languageCode;
      final country = locale.countryCode ?? 'US';
      final params = 'hl=$lang-$country&gl=$country&ceid=$country:$lang';
      final baseUrl = topic == null
          ? 'https://news.google.com/rss'
          : 'https://news.google.com/rss/search?q=${Uri.encodeComponent(topic)}';
      final url = topic == null ? '$baseUrl?$params' : '$baseUrl&$params';
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return [];
      }
      final feed = RssFeed.parse(response.body);
      return feed.items
              ?.where((i) => i.title != null && i.link != null)
              .map((i) => NewsItem(title: i.title!, link: i.link!))
              .toList() ??
          [];
    } catch (_) {
      return [];
    }
  }
}

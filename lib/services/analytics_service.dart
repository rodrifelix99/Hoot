import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provides event tracking using Amplitude.
class AnalyticsService {
  AnalyticsService._();

  static final Amplitude _amplitude = Amplitude.getInstance();

  /// Initializes the Amplitude SDK with the API key from `.env`.
  static Future<void> init() async {
    final apiKey = dotenv.env['AMPLITUDE_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      await _amplitude.init(apiKey);
    }
  }

  /// Logs when a challenge card is viewed.
  static Future<void> challengeCardViewed({
    required String challengeId,
    required String userId,
  }) {
    return _amplitude.logEvent('challenge_card_viewed', eventProperties: {
      'challengeId': challengeId,
      'userId': userId,
    });
  }

  /// Logs when the join button on a challenge is clicked.
  static Future<void> challengeJoinClicked({
    required String challengeId,
    required String userId,
  }) {
    return _amplitude.logEvent('challenge_join_clicked', eventProperties: {
      'challengeId': challengeId,
      'userId': userId,
    });
  }

  /// Logs when a post is created for a challenge.
  static Future<void> challengePostCreated({
    required String challengeId,
    required String userId,
  }) {
    return _amplitude.logEvent('challenge_post_created', eventProperties: {
      'challengeId': challengeId,
      'userId': userId,
    });
  }
}

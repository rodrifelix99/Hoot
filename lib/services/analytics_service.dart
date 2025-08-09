import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hoot/services/auth_service.dart';

/// Provides helpers for logging analytics events with common metadata.
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final AuthService _authService;
  PackageInfo? _packageInfo;

  AnalyticsService({
    FirebaseAnalytics? analytics,
    AuthService? authService,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _authService = authService ?? Get.find<AuthService>();

  /// Sets the analytics user identifier.
  Future<void> setUserId(String? userId) => _analytics.setUserId(id: userId);

  /// Logs a custom [name] event with optional [parameters].
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    final params = await _withDefaults(parameters);
    await _analytics.logEvent(name: name, parameters: params);
  }

  /// Logs a screen view event with [screenName] and optional [screenClass].
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    await logEvent('screen_view', parameters: {
      'screen_name': screenName,
      if (screenClass != null) 'screen_class': screenClass,
    });
  }

  Future<Map<String, Object?>> _withDefaults(
    Map<String, Object?>? parameters,
  ) async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    final uid = _authService.currentUser?.uid;
    return {
      if (uid != null) 'userId': uid,
      'timestamp': DateTime.now().toIso8601String(),
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'appVersion': _packageInfo!.version,
      'buildNumber': _packageInfo!.buildNumber,
      ...?parameters,
    };
  }
}

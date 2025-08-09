import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hoot/services/analytics_service.dart';
import 'package:hoot/services/toast_service.dart';

/// Service providing a simple API to report non fatal errors.
class ErrorService {
  ErrorService._();

  static AnalyticsService? get _analytics =>
      Get.isRegistered<AnalyticsService>()
          ? Get.find<AnalyticsService>()
          : null;

  static final _sensitivePattern =
      RegExp(r'([\w.%+-]+@[\w.-]+|\b\d{4,}\b)', multiLine: true);

  static String _redact(String input) =>
      input.replaceAll(_sensitivePattern, '[REDACTED]');

  /// Logs [error] to Crashlytics and shows a toast with [message].
  static Future<void> reportError(
    dynamic error, {
    String? message,
    StackTrace? stack,
  }) async {
    final sanitizedMessage =
        message != null ? _redact(message) : _redact(error.toString());
    final stackTrace = stack ?? StackTrace.current;
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: sanitizedMessage,
      );
    } else {
      print('ErrorService: ${_redact(error.toString())}');
    }
    if (_analytics != null) {
      final stackHash =
          sha1.convert(utf8.encode(_redact(stackTrace.toString()))).toString();
      await _analytics!.logEvent('error', parameters: {
        'type': _redact(error.runtimeType.toString()),
        'stackHash': stackHash,
        'message': sanitizedMessage,
      });
    }
    ToastService.showError(sanitizedMessage);
  }
}

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hoot/services/toast_service.dart';

/// Service providing a simple API to report non fatal errors.
class ErrorService {
  ErrorService._();

  /// Logs [error] to Crashlytics and shows a toast with [message].
  static Future<void> reportError(dynamic error,
      {String? message, StackTrace? stack}) async {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack ?? StackTrace.current,
      reason: message,
    );
    ToastService.showError(message ?? error.toString());
  }
}

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Logs a non-fatal error to Firebase Crashlytics and also prints the message in debug mode.
void logError(String message, [Exception? exception, StackTrace? stack]) {
  FirebaseCrashlytics.instance.recordError(
    exception ?? message,
    stack ?? StackTrace.current,
    reason: exception == null ? message : null,
  );
}

/// Logs general information to Firebase Crashlytics.
void logInfo(String message) {
  FirebaseCrashlytics.instance.log(message);
}

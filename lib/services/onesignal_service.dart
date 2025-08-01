import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Wrapper around the OneSignal SDK.
class OneSignalService extends GetxService {
  /// Initializes the OneSignal SDK.
  Future<void> init() async {
    OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  }

  /// Logs the user with [uid] into OneSignal.
  Future<void> login(String uid) {
    return OneSignal.login(uid);
  }

  /// Prompts the user for notification permissions.
  Future<bool> requestPermission() {
    return OneSignal.Notifications.requestPermission(true);
  }
}

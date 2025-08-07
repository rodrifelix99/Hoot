import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:hoot/util/routes/args/profile_args.dart';

/// Wrapper around the OneSignal SDK.
class OneSignalService extends GetxService {
  Map<String, dynamic>? _pendingData;

  /// Initializes the OneSignal SDK.
  Future<void> init() async {
    OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
    OneSignal.Notifications.addClickListener((event) {
      _pendingData = event.notification.additionalData;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => handlePendingNotification());
    });
  }

  /// Logs the user with [uid] into OneSignal.
  Future<void> login(String uid) {
    return OneSignal.login(uid);
  }

  /// Prompts the user for notification permissions.
  Future<bool> requestPermission() {
    return OneSignal.Notifications.requestPermission(true);
  }

  /// Returns whether requesting permission will show a prompt.
  Future<bool> canRequestPermission() {
    return OneSignal.Notifications.canRequest();
  }

  void handlePendingNotification() {
    final data = _pendingData;
    if (data == null) return;
    _pendingData = null;
    if (data['postId'] != null) {
      Get.toNamed(AppRoutes.post, arguments: {'id': data['postId']});
    } else if (data['action'] == 'view_feed_requests') {
      Get.toNamed(AppRoutes.feedRequests);
    } else if (data['feedId'] != null) {
      Get.toNamed(AppRoutes.feed,
          arguments: FeedPageArgs(feedId: data['feedId']));
    } else if (data['uid'] != null) {
      Get.toNamed(AppRoutes.profile, arguments: ProfileArgs(uid: data['uid']));
    }
  }
}

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:hoot/util/routes/args/profile_args.dart';
import 'package:hoot/services/analytics_service.dart';

/// Wrapper around the OneSignal SDK.
class OneSignalService extends GetxService {
  Map<String, dynamic>? _pendingData;

  AnalyticsService? get _analytics => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  /// Initializes the OneSignal SDK.
  Future<void> init() async {
    OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
    OneSignal.Notifications.addClickListener((event) {
      _pendingData = event.notification.additionalData;
      if (_analytics != null) {
        _analytics!.logEvent('onesignal_notification_click', parameters: {
          'notificationId': event.notification.notificationId,
          if (event.notification.additionalData != null)
            'payload': jsonEncode(event.notification.additionalData),
        });
      }
      WidgetsBinding.instance
          .addPostFrameCallback((_) => handlePendingNotification());
    });
  }

  /// Logs the user with [uid] into OneSignal.
  Future<void> login(String uid) async {
    await OneSignal.login(uid);
    if (_analytics != null) {
      await _analytics!.logEvent('onesignal_login', parameters: {
        'userId': uid,
      });
    }
  }

  /// Prompts the user for notification permissions.
  Future<bool> requestPermission() async {
    final result = await OneSignal.Notifications.requestPermission(true);
    if (_analytics != null) {
      await _analytics!.logEvent('onesignal_permission_prompt', parameters: {
        'accepted': result,
      });
    }
    return result;
  }

  /// Returns whether requesting permission will show a prompt.
  Future<bool> canRequestPermission() {
    return OneSignal.Notifications.canRequest();
  }

  /// Clears notifications and resets the app badge.
  Future<void> clearBadge() async {
    await OneSignal.Notifications.clearAll();
    if (_analytics != null) {
      await _analytics!.logEvent('onesignal_clear_badge');
    }
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

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialog_service.dart';
import 'feedback_service.dart';
import 'error_service.dart';

/// Service that tracks user actions and prompts for app reviews.
class AppReviewService extends GetxService {
  static const _actionKey = 'appReviewActionCount';
  static const _promptedKey = 'appReviewPrompted';
  final _inAppReview = InAppReview.instance;
  final int _threshold = 5;
  bool _handledThisSession = false;

  /// Records a user action and possibly prompts for review.
  Future<void> recordAction(BuildContext context) async {
    if (_handledThisSession) return;
    _handledThisSession = true;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_promptedKey) ?? false) return;
    final count = (prefs.getInt(_actionKey) ?? 0) + 1;
    await prefs.setInt(_actionKey, count);
    if (count < _threshold) return;

    final enjoy = await DialogService.confirm(
      context: context,
      title: 'rateAppEnjoying'.tr,
      message: 'rateAppQuestion'.tr,
      okLabel: 'yes'.tr,
      cancelLabel: 'no'.tr,
    );

    await prefs.setBool(_promptedKey, true);

    if (enjoy) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } else {
      final wantsFeedback = await DialogService.confirm(
        context: context,
        title: 'rateAppSorryTitle'.tr,
        message: 'rateAppSorryMessage'.tr,
        okLabel: 'sendFeedback'.tr,
        cancelLabel: 'cancel'.tr,
      );
      if (wantsFeedback) {
        BetterFeedback.of(context).show((feedback) async {
          try {
            await FeedbackService.submitFeedback(
              screenshot: feedback.screenshot,
              message: feedback.text,
            );
          } catch (e, s) {
            await ErrorService.reportError(e, stack: s);
          }
        });
      }
    }
  }
}

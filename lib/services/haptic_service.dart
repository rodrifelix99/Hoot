import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticService {
  HapticService._();

  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void tap(BuildContext context) {
    Feedback.forTap(context);
  }
}

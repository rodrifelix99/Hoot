import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../util/routes/app_routes.dart';
import '../util/routes/args/profile_args.dart';

/// Parses [text] and returns spans where @username mentions are highlighted
/// in blue and tappable to open the mentioned user's profile.
List<TextSpan> parseMentions(String text) {
  final authService =
      Get.isRegistered<AuthService>() ? Get.find<AuthService>() : AuthService();
  final regex = RegExp(r'@([A-Za-z0-9_]+)');
  final spans = <TextSpan>[];
  var currentIndex = 0;

  for (final match in regex.allMatches(text)) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
    }
    final username = match.group(1)!;
    spans.add(TextSpan(
      text: '@$username',
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final user = await authService.fetchUserByUsername(username);
          if (user != null) {
            Get.toNamed(AppRoutes.profile,
                arguments: ProfileArgs(uid: user.uid));
          }
        },
    ));
    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(text: text.substring(currentIndex)));
  }

  return spans;
}

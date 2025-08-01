import 'package:flutter/material.dart';
import 'package:hoot/models/feed.dart';

extension FeedExtension on Feed {
  Color get foregroundColor {
    final background = color;
    if (background == null) return Colors.white;

    if (background.computeLuminance() > 0.5) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}

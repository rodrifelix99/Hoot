import 'package:flutter/material.dart';

enum AppColor { blue, green, orange, pink, purple, red, yellow }

extension AppColorExtension on AppColor {
  Color get color {
    switch (this) {
      case AppColor.green:
        return Colors.green;
      case AppColor.orange:
        return Colors.orange;
      case AppColor.pink:
        return Colors.pink;
      case AppColor.purple:
        return Colors.purple;
      case AppColor.red:
        return Colors.red;
      case AppColor.yellow:
        return Colors.yellow;
      case AppColor.blue:
      default:
        return Colors.blue;
    }
  }

  String get asset => 'assets/images/bottom_bar_${name}.jpg';
}

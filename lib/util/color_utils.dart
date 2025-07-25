import 'package:flutter/material.dart';

/// Returns either [Colors.white] or [Colors.black] depending on the luminance
/// of the given [background] color. Colors with a luminance greater than 0.5
/// are considered light and will use [Colors.black] as the foreground color,
/// otherwise [Colors.white] is used.
Color foregroundForBackground(Color background) {
  return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color primaryColor = CupertinoColors.activeBlue;

  static const CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(fontFamily: 'Inter'),
    ),
  );

  static const CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(fontFamily: 'Inter'),
    ),
  );
}

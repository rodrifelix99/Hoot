import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static Color primaryColor = Colors.blue;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryColor,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
    ),
    snackBarTheme: snackBarTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: inputDecorationTheme,
    ),
    chipTheme: chipTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryColor,
    fontFamily: 'Inter',
    textTheme:  const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
    ),
    snackBarTheme: snackBarTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    inputDecorationTheme: inputDecorationTheme.copyWith(
      labelStyle: const TextStyle(color: Colors.white),
      fillColor: Colors.grey.shade800,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: inputDecorationTheme
    ),
    chipTheme: chipTheme.copyWith(
      backgroundColor: darkColorScheme.onPrimary,
      labelStyle: TextStyle(
        fontSize: 12,
        color: darkColorScheme.primary,
      ),
      iconTheme: IconThemeData(
        size: 16,
        color: darkColorScheme.primary
      ),
    )
  );
  
  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
  );
  
  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
  );

  static SnackBarThemeData snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),
      ),
      elevation: MaterialStateProperty.all(0),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
      backgroundColor: MaterialStateProperty.all(
        primaryColor,
      ),
      foregroundColor: MaterialStateProperty.all(
        Colors.white,
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    ),
  );

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );

  static ChipThemeData chipTheme = ChipThemeData(
    padding: const EdgeInsets.all(8),
    shape: const RoundedRectangleBorder(
      side: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(100)),
    ),
    side: BorderSide.none,
    backgroundColor: lightColorScheme.primary.withOpacity(0.25),
    labelStyle: TextStyle(
      fontSize: 12,
      color: lightColorScheme.primary,
    ),
    iconTheme: IconThemeData(
      color: lightColorScheme.primary,
      size: 16,
    ),
  );
}

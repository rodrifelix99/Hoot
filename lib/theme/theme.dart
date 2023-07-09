import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(),
    snackBarTheme: snackBarTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    chipTheme: chipTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme.copyWith(
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      decorationColor: Colors.white, // Set the decoration color to white
      displayColor: Colors.white, // Set the display color to white
      bodyColor: Colors.white, // Set the text color to white
    ),
    snackBarTheme: snackBarTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    inputDecorationTheme: inputDecorationTheme.copyWith(
      labelStyle: const TextStyle(color: Colors.white),
      fillColor: Colors.grey.shade800,
    ),
    chipTheme: chipTheme,
  );

  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light, // Set the brightness explicitly
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
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: MaterialStateProperty.all(0),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide.none,
        ),
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    ),
  );

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
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
    backgroundColor: colorScheme.primary.withOpacity(0.25),
    labelStyle: TextStyle(
      fontSize: 12,
      color: colorScheme.primary,
    ),
    iconTheme: IconThemeData(
      color: colorScheme.primary,
      size: 16,
    ),
  );
}

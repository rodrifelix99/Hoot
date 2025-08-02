import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(Color primaryColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      fontFamily: 'Inter',
      textTheme: _lightTextTheme,
      snackBarTheme: _snackBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme(primaryColor),
      inputDecorationTheme: _inputDecorationTheme,
      dropdownMenuTheme: _dropdownMenuTheme,
      chipTheme: _chipTheme(colorScheme, false),
    );
  }

  static ThemeData darkTheme(Color primaryColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      textTheme: _darkTextTheme,
      snackBarTheme: _snackBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme(primaryColor),
      inputDecorationTheme: _inputDecorationTheme.copyWith(
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.grey.shade800,
      ),
      dropdownMenuTheme: _dropdownMenuTheme,
      chipTheme: _chipTheme(colorScheme, true),
    );
  }

  static DropdownMenuThemeData get _dropdownMenuTheme => DropdownMenuThemeData(
        inputDecorationTheme: _inputDecorationTheme,
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.all(8),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
        ),
      );

  static TextTheme get _lightTextTheme =>
      GoogleFonts.lexendTextTheme().copyWith(
        bodySmall: GoogleFonts.interTextTheme().bodySmall,
        bodyMedium: GoogleFonts.interTextTheme().bodyMedium,
        bodyLarge: GoogleFonts.interTextTheme().bodyLarge,
      );

  static TextTheme get _darkTextTheme =>
      GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme).copyWith(
        bodySmall:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).bodySmall,
        bodyMedium:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).bodyMedium,
        bodyLarge:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).bodyLarge,
      );

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(Color color) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide.none,
            ),
          ),
          backgroundColor: WidgetStateProperty.all(color),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        alignLabelWithHint: true,
      );

  static ChipThemeData _chipTheme(ColorScheme scheme, bool dark) =>
      ChipThemeData(
        padding: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        side: BorderSide.none,
        backgroundColor: dark ? scheme.onPrimary : scheme.primary.withAlpha(64),
        labelStyle: TextStyle(
          fontSize: 12,
          color: scheme.primary,
        ),
        iconTheme: IconThemeData(color: scheme.primary, size: 16),
      );
}

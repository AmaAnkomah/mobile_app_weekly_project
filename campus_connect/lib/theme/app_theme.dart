import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryIndigo = Color(0xFF303F9F);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color darkSurface = Color(0xFF121212);
  static const Color lightSurface = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryIndigo,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.montserratTextTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryIndigo,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    );
  }
}

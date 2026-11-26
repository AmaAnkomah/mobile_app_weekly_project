import 'package:flutter/material.dart';

/// Campus Eats Design System
/// Dark theme with vibrant amber/orange accent — evoking warmth and food energy.
class AppTheme {
  // ── Colour Palette ──────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFFFF6B35); // Vibrant orange
  static const Color primaryDark  = Color(0xFFE85D2F);
  static const Color accent       = Color(0xFFFFB347); // Warm amber
  static const Color background   = Color(0xFF121212); // Deep dark
  static const Color surface      = Color(0xFF1E1E1E); // Card background
  static const Color surfaceAlt   = Color(0xFF252525); // Slightly lighter
  static const Color onPrimary    = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFF5F5F5);
  static const Color onSurface    = Color(0xFFE0E0E0);
  static const Color onSurfaceDim = Color(0xFF9E9E9E);
  static const Color error        = Color(0xFFCF6679);
  static const Color success      = Color(0xFF4CAF50);
  static const Color warning      = Color(0xFFFFC107);

  // Category colours
  static const Color breakfast    = Color(0xFF7986CB);
  static const Color lunch        = Color(0xFF4DB6AC);
  static const Color snacks       = Color(0xFFFFB74D);

  // ── Text Styles ─────────────────────────────────────────────────────────────
  static const TextTheme textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: onBackground, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: onBackground),
    displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onBackground),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onBackground),
    headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onBackground),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onBackground),
    titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onBackground),
    titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
    titleSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
    bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceDim),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onPrimary),
    labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
    labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: onSurfaceDim),
  );

  // ── Theme Data ───────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:    primary,
      secondary:  accent,
      surface:    surface,
      error:      error,
      onPrimary:  onPrimary,
      onSecondary: Colors.black,
      onSurface:  onSurface,
      onError:    Colors.white,
    ),
    scaffoldBackgroundColor: background,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: onBackground, letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: onBackground),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      hintStyle: const TextStyle(color: onSurfaceDim),
      labelStyle: const TextStyle(color: onSurfaceDim),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceDim,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceAlt,
      selectedColor: primary.withOpacity(0.2),
      labelStyle: const TextStyle(color: onSurface, fontSize: 12),
      secondaryLabelStyle: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(color: surfaceAlt, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceAlt,
      contentTextStyle: const TextStyle(color: onSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  // ── Helper Decorations ───────────────────────────────────────────────────────

  /// Glassmorphism container
  static BoxDecoration get glassCard => BoxDecoration(
    color: surface.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );

  /// Gradient header
  static BoxDecoration get headerGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [primary, primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast': return breakfast;
      case 'lunch':     return lunch;
      case 'snacks':    return snacks;
      default:          return accent;
    }
  }
}

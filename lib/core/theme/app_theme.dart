import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF012D1D);
  static const Color emerald = Color(0xFF10B981);
  static const Color primaryContainer = Color(0xFF1B4332);
  static const Color secondary = Color(0xFF77574D);
  static const Color background = Color(0xFFF9F9F7);
  static const Color onBackground = Color(0xFF1A1C1B);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFEEEEEC);
  static const Color surfaceContainerLow = Color(0xFFF4F4F2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1B);
  static const Color onSurfaceVariant = Color(0xFF414844);
  static const Color outline = Color(0xFF717973);
  static const Color tertiaryFixed = Color(0xFFDAE8BE);
  static const Color error = Color(0xFFBA1A1A);

  static BoxDecoration get heroGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [primary, primaryContainer],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: onSurface,
        background: background,
        onBackground: onBackground,
        error: error,
        onError: Colors.white,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 64,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1.5,
          color: onSurface,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1.0,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: secondary,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Common UI constants
  static const double horizontalSpacing = 24.0;
  static const double borderRadius = 16.0;
}

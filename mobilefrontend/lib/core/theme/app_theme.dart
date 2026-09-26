import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBg = Color(0xFF0F172A); // Slate 900
  static const Color secondaryBg = Color(0xFF1E293B); // Slate 800
  static const Color accentTeal = Color(0xFF2DD4BF); // Teal 400
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentPurple = Color(0xFFA855F7); // Purple 500
  static const Color criticalRed = Color(0xFFF87171); // Red 400
  static const Color warningYellow = Color(0xFFFBBC05); // Yellow 500

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x99FFFFFF); // 60% White
  static const Color textMuted = Color(0x33FFFFFF); // 20% White

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBg,
      primaryColor: accentTeal,
      colorScheme: const ColorScheme.dark(
        primary: accentTeal,
        secondary: accentBlue,
        surface: secondaryBg,
        onSurface: textPrimary,
        error: criticalRed,
      ),
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          fontStyle: FontStyle.italic,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          fontStyle: FontStyle.italic,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: textMuted,
          letterSpacing: 1.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0x05FFFFFF), // White with 2% opacity
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: Color(0x0DFFFFFF),
            width: 1,
          ), // 5% White
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTeal,
          foregroundColor: primaryBg,
          textStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0x08FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x0DFFFFFF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x802DD4BF), width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
    );
  }
}

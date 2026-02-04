import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Brand palette - Clean Tech Light
const Color primaryColor = Color(0xFF1E293B); // slate-800 / deep navy
const Color secondaryColor = Color(0xFF2E7D32); // emerald green (CTA)
const Color accentGoldColor = Color(0xFFF59E0B); // amber / gold accent

const Color backgroundColor = Color(0xFFF1F5F9); // light slate background
const Color surfaceColor = Color(0xFFFFFFFF); // clean white cards

// Typography colors (Slate Gray family)
const Color textColor = Color(0xFF0F172A); // slate-900
const Color mutedTextColor = Color(0xFF64748B); // slate-500

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textColor,
        onSurface: textColor,
        error: Colors.red,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ).copyWith(
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        shadowColor: Colors.black12,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: primaryColor.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: const TextStyle(color: mutedTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: const Color(0xFFCBD5E1)), // slate-300
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0)), // slate-200
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          elevation: 4,
          shadowColor: secondaryColor.withOpacity(0.3),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: mutedTextColor,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

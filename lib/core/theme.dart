import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFB91C1C); // Deep Red
  static const Color secondaryColor = Color(0xFFEF4444); // Lighter Red
  static const Color accentColor = Color(0xFFF59E0B); // Amber/Gold
  static const Color backgroundColor = Color(0xFFF9FAFB); // Softer Light Gray
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF111827); // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textSecondary, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF000000), // True black background
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF121212), // Sleek very dark gray for surfaces
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: const BorderSide(color: secondaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A), // Darker inputs
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardColor: const Color(0xFF121212),
      dividerColor: const Color(0xFF2C2C2C),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE63946);
  static const Color primaryDeep = Color(0xFF1B2A4A);
  static const Color accent = Color(0xFFFFA726);
  static const Color background = Color(0xFFF7F7F8);
  static const Color cardColor = Colors.white;
  static const Color muted = Color(0xFF9E9E9E);
  static const Color surface = Color(0xFFFFFFFF);

  // ======== FIX UNTUK ERROR =========
  static const Color primary = primaryRed;        // alias untuk AppColors.primary
  static const Color backgroundMain = background; // alias untuk AppColors.background
  // ==================================
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        base.textTheme,
      ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

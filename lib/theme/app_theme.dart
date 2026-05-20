import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark mode palette : black and orange ─────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color orangePrimary = Color(0xFFFF6B00);
  static const Color orangeAccent = Color(0xFFFF9A3C);
  static const Color orangeMuted = Color(0xFFCC5500);

  // ── Light mode palette : white, grey and purple ───────────────────────
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF4F4F6);
  static const Color lightCard = Color(0xFFEEEEF2);
  static const Color purplePrimary = Color(0xFF6B3FA0);
  static const Color purpleAccent = Color(0xFF9B6DD1);
  static const Color greyText = Color(0xFF5A5A6A);

  // ── Shared semantic colours ───────────────────────────────────────────
  static const Color correctGreen = Color(0xFF4CAF50);
  static const Color incorrectRed = Color(0xFFE53935);
  static const Color starGold = Color(0xFFFFD700);

  // ── Backward-compatible aliases ───────────────────────────────────────
  static const Color deepSpace = darkBg;
  static const Color surfaceDark = darkSurface;
  static const Color cardDark = darkCard;
  static const Color cosmicTeal = orangePrimary;
  static const Color nebulaPurple = orangeMuted;

  // ── Text themes ───────────────────────────────────────────────────────
  static TextTheme _darkTextTheme() {
    return GoogleFonts.exo2TextTheme().copyWith(
      headlineLarge: GoogleFonts.exo2(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.exo2(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.exo2(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.exo2(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFFD0D0D0)),
      bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
    );
  }

  static TextTheme _lightTextTheme() {
    return GoogleFonts.exo2TextTheme().copyWith(
      headlineLarge: GoogleFonts.exo2(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A1A)),
      headlineMedium: GoogleFonts.exo2(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A1A)),
      titleLarge: GoogleFonts.exo2(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A)),
      titleMedium: GoogleFonts.exo2(
          fontSize: 16, fontWeight: FontWeight.w500, color: greyText),
      bodyLarge: TextStyle(fontSize: 16, color: greyText),
      bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFF7A7A8A)),
    );
  }

  // ── Dark theme : black and orange ─────────────────────────────────────
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: _darkTextTheme(),
      colorScheme: const ColorScheme.dark(
        primary: orangePrimary,
        secondary: orangeAccent,
        surface: darkSurface,
        onPrimary: Colors.black,
        onSurface: Colors.white,
        // Prevent Material 3 tinting the nav bar surface
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.exo2(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: orangePrimary,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: orangePrimary,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangePrimary,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle:
              GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: orangePrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? orangePrimary : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? orangePrimary.withAlpha(100)
                : Colors.grey.withAlpha(100)),
      ),
      dividerColor: Colors.white12,
    );
  }

  // ── Light theme : white, grey and purple ──────────────────────────────
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: _lightTextTheme(),
      colorScheme: ColorScheme.light(
        primary: purplePrimary,
        secondary: purpleAccent,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        // Prevent Material 3 overriding nav bar with a tinted surface
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: purplePrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.exo2(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: purplePrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: purplePrimary),
      ),
      // ── Bottom nav bar : explicitly white background, purple icons ────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: purplePrimary,
        unselectedItemColor: greyText,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle:
            GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.exo2(fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purplePrimary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle:
              GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        hintStyle: TextStyle(color: greyText.withAlpha(150)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: purplePrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? purplePrimary
                : Colors.grey.shade400),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? purplePrimary.withAlpha(100)
                : Colors.grey.withAlpha(80)),
      ),
      dividerColor: const Color(0xFFDDDDE8),
    );
  }
}

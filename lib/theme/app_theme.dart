import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // COLORS
  static const Color primaryColor = Color(0xFFE50914);
  static const Color secondaryColor = Color(0xFF0071EB);
  static const Color accentColor = Color(0xFFFFBE0B);
  static const Color successColor = Color(0xFF1DB954);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color errorColor = Color(0xFFD32F2F);

  static const Color surfaceColor = Color(0xFF1F1F1F);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF262626);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),

    // Typography
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    // Components
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 4,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: surfaceColor,
      labelStyle: TextStyle(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: StadiumBorder(),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),

    // Tab bar
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: primaryColor,
    ),

    // Scaffolding
    scaffoldBackgroundColor: backgroundColor,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const seed = Color(0xFFD76B30); // orange accent

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: const Color(0xFF111827), // near-black
      displayColor: const Color(0xFF111827),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      elevation: 1,
    ),
    iconTheme: const IconThemeData(size: 20),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    visualDensity: VisualDensity.standard,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      elevation: 1,
    ),
  );

  // Spacing tokens
  static const gap8 = SizedBox(height: 8, width: 8);
  static const gap16 = SizedBox(height: 16, width: 16);
  static const gap24 = SizedBox(height: 24, width: 24);
}
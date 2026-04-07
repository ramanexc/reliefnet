import 'package:flutter/material.dart';

ThemeData darkmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF111827),
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF111827),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF374151),
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
  ),
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF111827),
    primary: const Color(0xFF2563EB),
    secondary: const Color(0xFF6366F1),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E3A8A),
    // surfaceTintColor: Color(0xFF2563EB),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1F2937),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2563EB)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  ),
);

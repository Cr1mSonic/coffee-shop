import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF6C4A3F),
  scaffoldBackgroundColor: Colors.transparent,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'OpenSans',
      color: Colors.white,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'OpenSans',
      color: Colors.white70,
      fontSize: 14,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 24,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C4A3F),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
);

class AppColors {
  static const Color darkBrown = Color(0xFF4B2C20);
  static const Color brown = Color(0xFF6C4A3F);
  static const Color mediumBrown = Color(0xFF8B5E3C);
  static const Color lightBrown = Color(0xFFD3A36A);
  static const Color beige = Color(0xFFF5E9DA);
}

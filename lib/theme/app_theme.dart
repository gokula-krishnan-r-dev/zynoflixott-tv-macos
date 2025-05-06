import 'package:flutter/material.dart';

/// Defines the app's color theme and styling
class AppTheme {
  // Primary brand colors
  static const Color primaryColor = Color(0xFFE50914);
  static const Color accentColor = Color(0xFF0071EB);
  
  // Background colors
  static const Color backgroundColor = Color(0xFF0C0C0C);
  static const Color surfaceColor = Color(0xFF1F1F1F);
  static const Color cardColor = Color(0xFF262626);
  
  // Text colors
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFB3B3B3);
  
  // Utility colors
  static const Color errorColor = Color(0xFFE87C03);
  static const Color successColor = Color(0xFF46D369);
  static const Color warningColor = Color(0xFFFFB13D);
  
  // TV App specific colors
  static const Color focusColor = Color(0xFFE50914);
  static const Color unfocusedColor = Color(0x80FFFFFF);
  
  // Theme 
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
      ),
    );
  }
} 
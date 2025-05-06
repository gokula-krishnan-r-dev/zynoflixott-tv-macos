import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0A84FF);
  static const Color backgroundColor = Color(0xFF000000);
  static const Color cardColor = Color(0xFF1C1C1E);
  static const Color surfaceColor = Color(0xFF2C2C2E);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFF8E8E93);
  static const Color accentColor = Color(0xFF30D158);
  static const Color focusColor = Color(0xFF0A84FF);
  static const Color errorColor = Color(0xFFFF453A);
  
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48.0,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 34.0,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundColor,
        indicatorColor: focusColor.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
        ),
      ),
      focusColor: focusColor,
    );
  }
} 
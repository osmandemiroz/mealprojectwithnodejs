import 'package:flutter/material.dart';

/// AppTheme class that defines the application's theme following Apple's Human Interface Guidelines
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Primary colors following Apple's SF color system
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color secondaryColor = Color(0xFF5856D6);
  static const Color accentColor = Color(0xFF34C759);

  /// Semantic colors for feedback
  static const Color successColor = Color(0xFF34C759);
  static const Color warningColor = Color(0xFFFF9500);
  static const Color errorColor = Color(0xFFFF3B30);

  /// Neutral colors for backgrounds and text
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF000000);
  static const Color textSecondaryColor = Color(0xFF8E8E93);

  /// Border and divider colors
  static const Color borderColor = Color(0xFFE5E5EA);
  static const Color dividerColor = Color(0xFFC6C6C8);

  /// Spacing constants following Apple's 8-point grid system
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  /// Border radius constants
  static const double borderRadiusSmall = 4;
  static const double borderRadiusMedium = 8;
  static const double borderRadiusLarge = 12;

  /// Text styles using SF Pro font
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.37,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.36,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.35,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 17,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
    height: 1.3,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.24,
    height: 1.3,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
    height: 1.3,
  );

  /// Get the light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        // The 'space' property is not valid for DividerThemeData, so we will remove it.
      ),
      cardTheme: CardThemeData(
        // Changed CardTheme to CardThemeData to match the expected type
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_settings.dart';
import '../models/color_theme_type.dart';

class AppTheme {
  static ThemeData build(AppSettings settings) {
    final isDark = settings.darkMode;
    final ct = settings.colorTheme;

    final bgColor = isDark ? ct.backgroundColorDark : ct.backgroundColor;
    final fgColor = isDark ? ct.barColorDark : ct.barColor;

    final baseTextTheme = GoogleFonts.atkinsonHyperlegibleTextTheme();
    final scaledTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: (57 * settings.fontSizeScale).clamp(32, 112),
        color: fgColor,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: (32 * settings.fontSizeScale).clamp(20, 64),
        color: fgColor,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (18 * settings.fontSizeScale).clamp(14, 36),
        color: fgColor,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (16 * settings.fontSizeScale).clamp(12, 32),
        color: fgColor,
      ),
    );

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: fgColor,
        onPrimary: bgColor,
        secondary: fgColor,
        onSecondary: bgColor,
        error: Colors.red,
        onError: Colors.white,
        surface: bgColor,
        onSurface: fgColor,
      ),
      textTheme: scaledTextTheme,
      iconTheme: IconThemeData(color: fgColor, size: 32 * settings.fontSizeScale),
    );
  }

  /// The bar fill color for the current settings.
  static Color barColor(AppSettings settings) {
    return settings.darkMode
        ? settings.colorTheme.barColorDark
        : settings.colorTheme.barColor;
  }

  /// The bar track (unfilled) color for the current settings.
  static Color trackColor(AppSettings settings) {
    final bg = settings.darkMode
        ? settings.colorTheme.backgroundColorDark
        : settings.colorTheme.backgroundColor;
    // Track is a muted version of the foreground color on the background.
    return Color.lerp(barColor(settings), bg, 0.75)!;
  }
}

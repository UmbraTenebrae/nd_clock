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
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: (32 * settings.fontSizeScale).clamp(20, 64),
        color: fgColor,
        fontWeight: FontWeight.w600,
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

    final cardSurface = isDark ? const Color(0xFF252421) : Colors.white;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

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
        surface: cardSurface,
        onSurface: fgColor,
      ),
      textTheme: scaledTextTheme,
      iconTheme: IconThemeData(color: fgColor, size: 32 * settings.fontSizeScale),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0.5,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Foreground color for UI elements and text.
  static Color barColor(AppSettings settings) {
    return settings.darkMode
        ? settings.colorTheme.barColorDark
        : settings.colorTheme.barColor;
  }

  /// Fill color for the elapsed portion of the progress bar.
  static Color barFillColor(AppSettings settings) {
    return settings.darkMode
        ? settings.colorTheme.barFillColorDark
        : settings.colorTheme.barFillColor;
  }

  /// Track (unfilled) color for the progress bar.
  static Color trackColor(AppSettings settings) {
    return settings.darkMode
        ? settings.colorTheme.barTrackColorDark
        : settings.colorTheme.barTrackColor;
  }
}

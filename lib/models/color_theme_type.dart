import 'package:flutter/material.dart';

enum ColorThemeType {
  defaultTheme,
  highContrast,
  deuteranopia,
  protanopia,
  tritanopia,
}

extension ColorThemeData on ColorThemeType {
  String get label {
    switch (this) {
      case ColorThemeType.defaultTheme:
        return 'Default';
      case ColorThemeType.highContrast:
        return 'High Contrast';
      case ColorThemeType.deuteranopia:
        return 'Deuteranopia';
      case ColorThemeType.protanopia:
        return 'Protanopia';
      case ColorThemeType.tritanopia:
        return 'Tritanopia';
    }
  }

  /// Foreground color for text and UI elements in light mode.
  Color get barColor {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        return Colors.black;
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFF0057B7); // blue
      case ColorThemeType.tritanopia:
        return const Color(0xFFCC0000); // red
    }
  }

  /// Foreground color for text and UI elements in dark mode.
  Color get barColorDark {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        return Colors.white;
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFF90CAF9); // light blue
      case ColorThemeType.tritanopia:
        return const Color(0xFFEF9A9A); // light red
    }
  }

  /// Fill color for the elapsed portion of the progress bar (light mode).
  Color get barFillColor {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        return const Color(0xFFD32F2F); // red — clear elapsed signal
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFF0057B7); // blue — safe for red-green colorblind
      case ColorThemeType.tritanopia:
        return const Color(0xFFCC0000); // red — safe for blue-yellow colorblind
    }
  }

  /// Fill color for the elapsed portion of the progress bar (dark mode).
  Color get barFillColorDark {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        return const Color(0xFFEF5350); // lighter red on dark bg
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFF90CAF9); // light blue
      case ColorThemeType.tritanopia:
        return const Color(0xFFEF9A9A); // light red
    }
  }

  /// Track (unfilled bar) color in light mode — neutral grey for all themes.
  Color get barTrackColor {
    return const Color(0xFFBDBDBD); // grey 400
  }

  /// Track (unfilled bar) color in dark mode.
  Color get barTrackColorDark {
    return const Color(0xFF616161); // grey 700
  }

  /// Scaffold background color in light mode.
  Color get backgroundColor {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        return Colors.white;
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFFFFF176); // light yellow
      case ColorThemeType.tritanopia:
        return const Color(0xFF008080); // teal
    }
  }

  /// Scaffold background color in dark mode.
  Color get backgroundColorDark {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        return Colors.black;
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFF1A237E); // dark navy
      case ColorThemeType.tritanopia:
        return const Color(0xFF004D40); // dark teal
    }
  }

  /// Color for upcoming event tick marks in light mode.
  Color get eventColor {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        // Bar is now red; use black so ticks contrast with both red fill and grey track.
        return Colors.black;
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        // Red-green blind: orange is distinct from the blue bar.
        return const Color(0xFFE65100); // deep orange
      case ColorThemeType.tritanopia:
        // Blue-yellow blind: purple is distinct from the red bar.
        return const Color(0xFF7B1FA2); // purple
    }
  }

  /// Color for upcoming event tick marks in dark mode.
  Color get eventColorDark {
    switch (this) {
      case ColorThemeType.defaultTheme:
      case ColorThemeType.highContrast:
        // Bar is red on black; white ticks contrast with both.
        return Colors.white;
      case ColorThemeType.deuteranopia:
      case ColorThemeType.protanopia:
        return const Color(0xFFFF8F00); // amber-orange on dark navy
      case ColorThemeType.tritanopia:
        return const Color(0xFFCE93D8); // light purple on dark teal
    }
  }
}

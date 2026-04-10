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

  /// Bar (filled) color in light mode.
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

  /// Background (unfilled) color in light mode.
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
}

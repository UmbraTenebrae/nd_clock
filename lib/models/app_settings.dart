import 'package:flutter/material.dart';
import 'view_type.dart';
import 'color_theme_type.dart';
import 'selector_mode.dart';
import 'app_event.dart';

/// All caregiver-controlled configuration for the app.
/// Persisted via SharedPreferences.
class AppSettings {
  // --- Time view range ---
  final bool useCustomRange;
  final bool use24Hour;
  final TimeOfDay customStartTime;
  final TimeOfDay customEndTime;

  // --- Active views ---
  final List<ViewType> enabledViews;
  final ViewType activeView;

  // --- View selector display ---
  final SelectorMode selectorMode;

  // --- Visual ---
  final ColorThemeType colorTheme;
  final bool darkMode;
  final double fontSizeScale; // 1.0 = default

  // --- Caregiver enables these options for the child to toggle ---
  final bool caregiverAllowStartEnd;
  final bool caregiverAllowCountdown;
  final bool caregiverAllowProportion;

  // --- Child's current toggle state (persisted so it survives restarts) ---
  final bool childShowStartEnd;
  final bool childShowCountdown;
  final bool childShowProportion;

  // --- Events (time view only) ---
  final List<AppEvent> events;
  final bool caregiverAllowEventLabels;
  final bool childShowEventLabels;

  const AppSettings({
    this.useCustomRange = false,
    this.use24Hour = false,
    this.customStartTime = const TimeOfDay(hour: 0, minute: 0),
    this.customEndTime = const TimeOfDay(hour: 23, minute: 59),
    this.enabledViews = const [
      ViewType.time,
      ViewType.day,
      ViewType.week,
      ViewType.month,
      ViewType.year,
    ],
    this.activeView = ViewType.day,
    this.selectorMode = SelectorMode.iconAndWord,
    this.colorTheme = ColorThemeType.defaultTheme,
    this.darkMode = false,
    this.fontSizeScale = 1.0,
    this.caregiverAllowStartEnd = true,
    this.caregiverAllowCountdown = true,
    this.caregiverAllowProportion = true,
    this.childShowStartEnd = true,
    this.childShowCountdown = false,
    this.childShowProportion = false,
    this.events = const [],
    this.caregiverAllowEventLabels = true,
    this.childShowEventLabels = true,
  });

  AppSettings copyWith({
    bool? useCustomRange,
    bool? use24Hour,
    TimeOfDay? customStartTime,
    TimeOfDay? customEndTime,
    List<ViewType>? enabledViews,
    ViewType? activeView,
    SelectorMode? selectorMode,
    ColorThemeType? colorTheme,
    bool? darkMode,
    double? fontSizeScale,
    bool? caregiverAllowStartEnd,
    bool? caregiverAllowCountdown,
    bool? caregiverAllowProportion,
    bool? childShowStartEnd,
    bool? childShowCountdown,
    bool? childShowProportion,
    List<AppEvent>? events,
    bool? caregiverAllowEventLabels,
    bool? childShowEventLabels,
  }) {
    return AppSettings(
      useCustomRange: useCustomRange ?? this.useCustomRange,
      use24Hour: use24Hour ?? this.use24Hour,
      customStartTime: customStartTime ?? this.customStartTime,
      customEndTime: customEndTime ?? this.customEndTime,
      enabledViews: enabledViews ?? this.enabledViews,
      activeView: activeView ?? this.activeView,
      selectorMode: selectorMode ?? this.selectorMode,
      colorTheme: colorTheme ?? this.colorTheme,
      darkMode: darkMode ?? this.darkMode,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      caregiverAllowStartEnd:
          caregiverAllowStartEnd ?? this.caregiverAllowStartEnd,
      caregiverAllowCountdown:
          caregiverAllowCountdown ?? this.caregiverAllowCountdown,
      caregiverAllowProportion:
          caregiverAllowProportion ?? this.caregiverAllowProportion,
      childShowStartEnd: childShowStartEnd ?? this.childShowStartEnd,
      childShowCountdown: childShowCountdown ?? this.childShowCountdown,
      childShowProportion: childShowProportion ?? this.childShowProportion,
      events: events ?? this.events,
      caregiverAllowEventLabels:
          caregiverAllowEventLabels ?? this.caregiverAllowEventLabels,
      childShowEventLabels: childShowEventLabels ?? this.childShowEventLabels,
    );
  }
}

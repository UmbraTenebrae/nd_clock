import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/app_event.dart';
import '../models/view_type.dart';
import '../models/color_theme_type.dart';
import '../models/selector_mode.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _prefix = 'nd_clock_';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final enabledViewNames =
        prefs.getStringList('${_prefix}enabledViews') ??
            ViewType.values.map((v) => v.name).toList();
    final enabledViews = enabledViewNames
        .map((n) => ViewType.values.firstWhere((v) => v.name == n,
            orElse: () => ViewType.day))
        .toList();

    final activeViewName =
        prefs.getString('${_prefix}activeView') ?? ViewType.day.name;
    final activeView = ViewType.values
        .firstWhere((v) => v.name == activeViewName, orElse: () => ViewType.day);

    final colorThemeName =
        prefs.getString('${_prefix}colorTheme') ??
            ColorThemeType.defaultTheme.name;
    final colorTheme = ColorThemeType.values.firstWhere(
        (v) => v.name == colorThemeName,
        orElse: () => ColorThemeType.defaultTheme);

    final selectorModeName =
        prefs.getString('${_prefix}selectorMode') ??
            SelectorMode.iconAndWord.name;
    final selectorMode = SelectorMode.values.firstWhere(
        (v) => v.name == selectorModeName,
        orElse: () => SelectorMode.iconAndWord);

    final startHour =
        prefs.getInt('${_prefix}customStartHour') ?? 0;
    final startMinute =
        prefs.getInt('${_prefix}customStartMinute') ?? 0;
    final endHour =
        prefs.getInt('${_prefix}customEndHour') ?? 23;
    final endMinute =
        prefs.getInt('${_prefix}customEndMinute') ?? 59;

    state = AppSettings(
      useCustomRange: prefs.getBool('${_prefix}useCustomRange') ?? false,
      use24Hour: prefs.getBool('${_prefix}use24Hour') ?? false,
      customStartTime: TimeOfDay(hour: startHour, minute: startMinute),
      customEndTime: TimeOfDay(hour: endHour, minute: endMinute),
      enabledViews: enabledViews,
      activeView: activeView,
      selectorMode: selectorMode,
      colorTheme: colorTheme,
      darkMode: prefs.getBool('${_prefix}darkMode') ?? false,
      fontSizeScale: prefs.getDouble('${_prefix}fontSizeScale') ?? 1.0,
      caregiverAllowStartEnd:
          prefs.getBool('${_prefix}caregiverAllowStartEnd') ?? true,
      caregiverAllowCountdown:
          prefs.getBool('${_prefix}caregiverAllowCountdown') ?? true,
      caregiverAllowProportion:
          prefs.getBool('${_prefix}caregiverAllowProportion') ?? true,
      childShowStartEnd:
          prefs.getBool('${_prefix}childShowStartEnd') ?? true,
      childShowCountdown:
          prefs.getBool('${_prefix}childShowCountdown') ?? false,
      childShowProportion:
          prefs.getBool('${_prefix}childShowProportion') ?? false,
      events: _loadEvents(prefs),
      caregiverAllowEventLabels:
          prefs.getBool('${_prefix}caregiverAllowEventLabels') ?? true,
      childShowEventLabels:
          prefs.getBool('${_prefix}childShowEventLabels') ?? true,
      eventChimesEnabled:
          prefs.getBool('${_prefix}eventChimesEnabled') ?? true,
    );
  }

  List<AppEvent> _loadEvents(SharedPreferences prefs) {
    final raw = prefs.getString('${_prefix}events');
    if (raw == null || raw.isEmpty) return [];
    try {
      return AppEvent.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}useCustomRange', state.useCustomRange);
    await prefs.setBool('${_prefix}use24Hour', state.use24Hour);
    await prefs.setInt(
        '${_prefix}customStartHour', state.customStartTime.hour);
    await prefs.setInt(
        '${_prefix}customStartMinute', state.customStartTime.minute);
    await prefs.setInt('${_prefix}customEndHour', state.customEndTime.hour);
    await prefs.setInt(
        '${_prefix}customEndMinute', state.customEndTime.minute);
    await prefs.setStringList(
        '${_prefix}enabledViews',
        state.enabledViews.map((v) => v.name).toList());
    await prefs.setString('${_prefix}activeView', state.activeView.name);
    await prefs.setString(
        '${_prefix}selectorMode', state.selectorMode.name);
    await prefs.setString('${_prefix}colorTheme', state.colorTheme.name);
    await prefs.setBool('${_prefix}darkMode', state.darkMode);
    await prefs.setDouble('${_prefix}fontSizeScale', state.fontSizeScale);
    await prefs.setBool(
        '${_prefix}caregiverAllowStartEnd', state.caregiverAllowStartEnd);
    await prefs.setBool(
        '${_prefix}caregiverAllowCountdown', state.caregiverAllowCountdown);
    await prefs.setBool(
        '${_prefix}caregiverAllowProportion', state.caregiverAllowProportion);
    await prefs.setBool(
        '${_prefix}childShowStartEnd', state.childShowStartEnd);
    await prefs.setBool(
        '${_prefix}childShowCountdown', state.childShowCountdown);
    await prefs.setBool(
        '${_prefix}childShowProportion', state.childShowProportion);
    await prefs.setString(
        '${_prefix}events', AppEvent.encodeList(state.events));
    await prefs.setBool(
        '${_prefix}caregiverAllowEventLabels', state.caregiverAllowEventLabels);
    await prefs.setBool(
        '${_prefix}childShowEventLabels', state.childShowEventLabels);
    await prefs.setBool(
        '${_prefix}eventChimesEnabled', state.eventChimesEnabled);
  }

  void update(AppSettings Function(AppSettings) updater) {
    state = updater(state);
    _save();
  }

  // --- Convenience child-facing mutations ---

  void setActiveView(ViewType view) => update((s) => s.copyWith(activeView: view));

  void toggleChildStartEnd() =>
      update((s) => s.copyWith(childShowStartEnd: !s.childShowStartEnd));

  void toggleChildCountdown() =>
      update((s) => s.copyWith(childShowCountdown: !s.childShowCountdown));

  void toggleChildProportion() =>
      update((s) => s.copyWith(childShowProportion: !s.childShowProportion));

  void toggleChildEventLabels() =>
      update((s) => s.copyWith(childShowEventLabels: !s.childShowEventLabels));

  // --- Event CRUD ---

  void addEvent(AppEvent event) =>
      update((s) => s.copyWith(events: [...s.events, event]));

  void updateEvent(AppEvent event) => update((s) => s.copyWith(
      events: s.events.map((e) => e.id == event.id ? event : e).toList()));

  void deleteEvent(String id) =>
      update((s) => s.copyWith(events: s.events.where((e) => e.id != id).toList()));
}

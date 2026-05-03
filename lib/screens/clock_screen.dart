import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clock_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/time_utils.dart';
import '../widgets/time_progress_bar.dart';
import '../widgets/view_selector.dart';
import '../widgets/proportion_pie.dart';
import '../models/app_event.dart';
import '../models/app_settings.dart';
import '../models/selector_mode.dart';
import '../models/view_type.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';
import '../services/widget_service.dart';
import '../services/chime_service.dart';

class ClockScreen extends ConsumerStatefulWidget {
  const ClockScreen({super.key});

  @override
  ConsumerState<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends ConsumerState<ClockScreen> {
  int _lastWidgetMinute = -1;
  int _lastDayOfYear = -1;
  // IDs of events whose chime has already fired today (or that were already
  // past when the app started). Cleared on day rollover.
  final Set<String> _triggeredToday = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _lastDayOfYear = _dayOfYear(now);
    // Pre-mark already-passed events so the chime doesn't fire late on launch.
    final settings = ref.read(settingsProvider);
    _markPastEventsTriggered(settings.events, now);
  }

  int _dayOfYear(DateTime dt) =>
      dt.difference(DateTime(dt.year, 1, 1)).inDays;

  void _markPastEventsTriggered(List<AppEvent> events, DateTime now) {
    final nowMinutes = now.hour * 60 + now.minute;
    for (final event in events) {
      final eventMinutes = event.time.hour * 60 + event.time.minute;
      if (eventMinutes <= nowMinutes) _triggeredToday.add(event.id);
    }
  }

  void _onLongPressEnd(LongPressEndDetails _) => _openSettings();

  void _onLongPressCancel() {}

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final clockAsync = ref.watch(clockProvider);

    // Settings changes: handle event additions/edits/deletions so that newly
    // added past-time events don't fire late, and time edits re-arm.
    ref.listen<AppSettings>(settingsProvider, (prev, next) {
      final prevById = {
        for (final e in (prev?.events ?? const <AppEvent>[])) e.id: e
      };
      final now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;
      for (final event in next.events) {
        final prevEvent = prevById[event.id];
        final eventMinutes = event.time.hour * 60 + event.time.minute;
        if (prevEvent == null) {
          if (eventMinutes <= nowMinutes) _triggeredToday.add(event.id);
        } else if (prevEvent.time != event.time) {
          if (eventMinutes <= nowMinutes) {
            _triggeredToday.add(event.id);
          } else {
            _triggeredToday.remove(event.id);
          }
        }
      }
      final nextIds = next.events.map((e) => e.id).toSet();
      _triggeredToday.removeWhere((id) => !nextIds.contains(id));
    });

    // Per-tick: chime check, day rollover, and minute-aligned widget push.
    ref.listen<AsyncValue<DateTime>>(clockProvider, (_, next) {
      final now = next.valueOrNull;
      if (now == null) return;

      final today = _dayOfYear(now);
      if (today != _lastDayOfYear) {
        _lastDayOfYear = today;
        _triggeredToday.clear();
        _markPastEventsTriggered(ref.read(settingsProvider).events, now);
      }

      if (settings.eventChimesEnabled) {
        for (final event in settings.events) {
          if (_triggeredToday.contains(event.id)) continue;
          if (event.time.hour == now.hour &&
              event.time.minute == now.minute) {
            _triggeredToday.add(event.id);
            ChimeService.play();
          }
        }
      }

      if (now.minute != _lastWidgetMinute) {
        _lastWidgetMinute = now.minute;
        WidgetService.update(ref.read(settingsProvider), now);
      }
    });

    // Keep fully immersive; re-apply on every build in case system restores chrome.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final now = clockAsync.valueOrNull ?? DateTime.now();
    final view = settings.activeView;
    final progress = progressFor(view, now, settings);
    final timeString = currentDisplayLabel(view, now, settings);

    return Scaffold(
      body: GestureDetector(
        onLongPressEnd: _onLongPressEnd,
        onLongPressCancel: _onLongPressCancel,
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _PortraitLayout(
                      settings: settings,
                      now: now,
                      view: view,
                      progress: progress,
                      timeString: timeString,
                      onSelect: (v) => ref
                          .read(settingsProvider.notifier)
                          .setActiveView(v),
                    )
                  : _LandscapeLayout(
                      settings: settings,
                      now: now,
                      view: view,
                      progress: progress,
                      timeString: timeString,
                      onSelect: (v) => ref
                          .read(settingsProvider.notifier)
                          .setActiveView(v),
                    );
            },
          ),
        ),
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// Portrait layout — vertical stack
// ---------------------------------------------------------------------------

class _PortraitLayout extends StatelessWidget {
  final AppSettings settings;
  final DateTime now;
  final ViewType view;
  final double progress;
  final String timeString;
  final void Function(ViewType) onSelect;

  const _PortraitLayout({
    required this.settings,
    required this.now,
    required this.view,
    required this.progress,
    required this.timeString,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final deviceScale = isTablet ? 1.5 : 1.0;
    final textScale = isTablet ? 1.4 : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        // On tablet use width-based horizontal padding; on phone use height-based
        // (which naturally fits the narrow portrait proportions).
        final hPad = isTablet ? w * 0.06 : h * 0.06;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: h * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Time, bar, and labels — scaled up on tablet.
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          timeString,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                      TimeProgressBar(
                        progress: progress,
                        settings: settings,
                        now: now,
                        deviceScale: deviceScale,
                      ),
                      _StartEndLabels(settings: settings, now: now, view: view),
                      SizedBox(height: h * 0.02),
                      _RemainingLabels(
                          settings: settings,
                          now: now,
                          view: view,
                          progress: progress),
                    ],
                  ),
                ),
              ),
              // Controls — not scaled; touch targets stay at a sensible size.
              _DisplayToggles(settings: settings),
              SizedBox(height: h * 0.02),
              ViewSelector(settings: settings, onSelect: onSelect),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Landscape layout — bar centred vertically, controls on sides
// ---------------------------------------------------------------------------

class _LandscapeLayout extends StatelessWidget {
  final AppSettings settings;
  final DateTime now;
  final ViewType view;
  final double progress;
  final String timeString;
  final void Function(ViewType) onSelect;

  const _LandscapeLayout({
    required this.settings,
    required this.now,
    required this.view,
    required this.progress,
    required this.timeString,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final deviceScale = isTablet ? 1.5 : 1.0;
    final textScale = isTablet ? 1.4 : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: w * 0.04, vertical: h * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main content — scaled up on tablet.
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          timeString,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                      TimeProgressBar(
                        progress: progress,
                        settings: settings,
                        now: now,
                        deviceScale: deviceScale,
                      ),
                      _StartEndLabels(settings: settings, now: now, view: view),
                      SizedBox(height: h * 0.02),
                      _RemainingLabels(
                          settings: settings,
                          now: now,
                          view: view,
                          progress: progress),
                    ],
                  ),
                ),
              ),
              // Bottom row: toggles + view selector — not scaled.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _DisplayToggles(settings: settings)),
                  SizedBox(width: w * 0.02),
                  _CompactViewSelector(settings: settings, onSelect: onSelect),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _StartEndLabels extends StatelessWidget {
  final AppSettings settings;
  final DateTime now;
  final ViewType view;

  const _StartEndLabels(
      {required this.settings, required this.now, required this.view});

  @override
  Widget build(BuildContext context) {
    if (!settings.caregiverAllowStartEnd || !settings.childShowStartEnd) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(startLabelFor(view, now, settings),
              style: Theme.of(context).textTheme.bodyLarge),
          Text(endLabelFor(view, now, settings),
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _RemainingLabels extends StatelessWidget {
  final AppSettings settings;
  final DateTime now;
  final ViewType view;
  final double progress;

  const _RemainingLabels({
    required this.settings,
    required this.now,
    required this.view,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final showCountdown =
        settings.caregiverAllowCountdown && settings.childShowCountdown;
    final showProportion =
        settings.caregiverAllowProportion && settings.childShowProportion;
    if (!showCountdown && !showProportion) return const SizedBox.shrink();

    final nextEvent = showCountdown
        ? nextEventLabel(view, now, settings)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showCountdown)
          Text(countdownLabel(view, now, settings),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge),
        if (nextEvent != null)
          Text(nextEvent,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge),
        if (showProportion)
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProportionPie(progress: progress, settings: settings),
              const SizedBox(width: 8),
              Flexible(
                child: Text(proportionLabel(progress),
                    style: Theme.of(context).textTheme.headlineLarge),
              ),
            ],
          ),
      ],
    );
  }
}

/// Compact horizontal view selector used in the landscape bottom row.
/// Mirrors ViewSelector but with tighter padding so it sits beside the toggles.
class _CompactViewSelector extends StatelessWidget {
  final AppSettings settings;
  final void Function(ViewType) onSelect;

  const _CompactViewSelector(
      {required this.settings, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final trayColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final selectedBg = isDark ? const Color(0xFF2E2C2A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trayColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: settings.enabledViews.map((view) {
          final isActive = view == settings.activeView;
          final color = isActive ? fg : fg.withValues(alpha: 0.45);
          return GestureDetector(
            onTap: () => onSelect(view),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: isActive
                  ? BoxDecoration(
                      color: selectedBg,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: isDark ? 0.30 : 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
              child: switch (settings.selectorMode) {
                SelectorMode.iconOnly =>
                  Icon(view.icon, color: color, size: 22),
                SelectorMode.wordOnly => Text(view.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.normal)),
                SelectorMode.iconAndWord => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(view.icon, color: color, size: 22),
                      const SizedBox(height: 2),
                      Text(view.label,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.normal)),
                    ],
                  ),
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Row of large toggle buttons for child-accessible display options.
class _DisplayToggles extends ConsumerWidget {
  final AppSettings settings;

  const _DisplayToggles({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final fg = AppTheme.barColor(settings);

    final toggles = <Widget>[];

    if (settings.caregiverAllowStartEnd) {
      toggles.add(_ToggleButton(
        label: 'Start/End',
        icon: Icons.straighten_rounded,
        active: settings.childShowStartEnd,
        color: fg,
        onTap: notifier.toggleChildStartEnd,
      ));
    }

    if (settings.caregiverAllowCountdown) {
      toggles.add(_ToggleButton(
        label: 'Time left',
        icon: Icons.hourglass_bottom_rounded,
        active: settings.childShowCountdown,
        color: fg,
        onTap: notifier.toggleChildCountdown,
      ));
    }

    if (settings.caregiverAllowProportion) {
      toggles.add(_ToggleButton(
        label: 'How much',
        icon: Icons.pie_chart_rounded,
        active: settings.childShowProportion,
        color: fg,
        onTap: notifier.toggleChildProportion,
      ));
    }

    if (settings.caregiverAllowEventLabels && settings.events.isNotEmpty) {
      toggles.add(_ToggleButton(
        label: 'Events',
        icon: Icons.label_rounded,
        active: settings.childShowEventLabels,
        color: fg,
        onTap: notifier.toggleChildEventLabels,
      ));
    }

    if (toggles.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: toggles.map((t) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: t,
      ))).toList(),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : color.withValues(alpha: 0.22),
            width: active ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? color : color.withValues(alpha: 0.45), size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? color : color.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

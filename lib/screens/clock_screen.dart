import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clock_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/time_utils.dart';
import '../widgets/time_progress_bar.dart';
import '../widgets/view_selector.dart';
import '../models/app_settings.dart';
import '../models/selector_mode.dart';
import '../models/view_type.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ClockScreen extends ConsumerStatefulWidget {
  const ClockScreen({super.key});

  @override
  ConsumerState<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends ConsumerState<ClockScreen> {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: h * 0.06, vertical: h * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Time, bar, and labels grouped and centred in available space
              Expanded(
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
                    TimeProgressBar(progress: progress, settings: settings),
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
              // Controls anchored to the bottom
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
              // Main content fills available space and centres itself
              Expanded(
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
                    TimeProgressBar(progress: progress, settings: settings),
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
              // Bottom row: toggles + view selector always at the bottom
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showCountdown)
          Text(countdownLabel(view, now, settings),
              style: Theme.of(context).textTheme.headlineLarge),
        if (showProportion)
          Text(proportionLabel(progress),
              style: Theme.of(context).textTheme.headlineLarge),
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
    final bg = theme.scaffoldBackgroundColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: settings.enabledViews.map((view) {
        final isActive = view == settings.activeView;
        final color = isActive ? bg : fg;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: () => onSelect(view),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isActive ? fg : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: fg, width: isActive ? 0 : 1.5),
              ),
              child: switch (settings.selectorMode) {
                SelectorMode.iconOnly =>
                  Icon(view.icon, color: color, size: 22),
                SelectorMode.wordOnly => Text(view.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.bold
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
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ],
                  ),
              },
            ),
          ),
        );
      }).toList(),
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? color : color.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? color : color.withValues(alpha: 0.5), size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: active ? color : color.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

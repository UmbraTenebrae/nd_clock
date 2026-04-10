import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clock_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/time_utils.dart';
import '../widgets/time_progress_bar.dart';
import '../widgets/view_selector.dart';
import '../models/app_settings.dart';
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

    return Scaffold(
      body: GestureDetector(
        // 3-second long-press anywhere opens settings.
        onLongPressEnd: _onLongPressEnd,
        onLongPressCancel: _onLongPressCancel,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current time
                Center(
                  child: Text(
                    _formatCurrentTime(now, settings.use24Hour),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                const Spacer(),

                // Progress bar
                TimeProgressBar(progress: progress, settings: settings),

                // Start / end labels
                if (settings.caregiverAllowStartEnd && settings.childShowStartEnd)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          startLabelFor(view, now, settings),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          endLabelFor(view, now, settings),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Time remaining: countdown
                if (settings.caregiverAllowCountdown && settings.childShowCountdown)
                  Center(
                    child: Text(
                      countdownLabel(view, now, settings),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),

                // Time remaining: proportion
                if (settings.caregiverAllowProportion && settings.childShowProportion)
                  Center(
                    child: Text(
                      proportionLabel(progress),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),

                const Spacer(),

                // Child-facing display toggles
                _DisplayToggles(settings: settings),

                const SizedBox(height: 16),

                // View selector
                ViewSelector(
                  settings: settings,
                  onSelect: (v) =>
                      ref.read(settingsProvider.notifier).setActiveView(v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrentTime(DateTime now, bool use24Hour) {
    if (use24Hour) {
      return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
    final period = now.hour < 12 ? 'AM' : 'PM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    return '$hour:${now.minute.toString().padLeft(2, '0')} $period';
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

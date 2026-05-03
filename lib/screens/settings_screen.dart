import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../models/app_event.dart';
import '../models/view_type.dart';
import '../models/color_theme_type.dart';
import '../models/selector_mode.dart';

/// Caregiver-only settings screen. Accessed via long-press on the clock screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // --- Time format ---
          _SectionHeader('Time Format'),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('24-hour time'),
              value: settings.use24Hour,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(use24Hour: v)),
            ),
          ]),

          // --- Custom time range ---
          _SectionHeader('Time View Range'),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('Use custom time range'),
              subtitle: const Text('Set a specific start and end time'),
              value: settings.useCustomRange,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(useCustomRange: v)),
            ),
            if (settings.useCustomRange) ...[
              _TimePicker(
                label: 'Start time',
                time: settings.customStartTime,
                onChanged: (t) =>
                    notifier.update((s) => s.copyWith(customStartTime: t)),
              ),
              _TimePicker(
                label: 'End time',
                time: settings.customEndTime,
                onChanged: (t) =>
                    notifier.update((s) => s.copyWith(customEndTime: t)),
              ),
            ],
          ]),

          // --- Enabled views ---
          _SectionHeader('Available Views'),
          _SettingsCard(children: [
            ...ViewType.values.map((view) {
              final enabled = settings.enabledViews.contains(view);
              return SwitchListTile(
                title: Text(view.label),
                value: enabled,
                onChanged: (v) {
                  final next = List<ViewType>.from(settings.enabledViews);
                  if (v) {
                    next.add(view);
                    next.sort((a, b) =>
                        ViewType.values.indexOf(a) -
                        ViewType.values.indexOf(b));
                  } else {
                    if (next.length <= 1) return;
                    next.remove(view);
                  }
                  final newActive = next.contains(settings.activeView)
                      ? settings.activeView
                      : next.first;
                  notifier.update(
                      (s) => s.copyWith(enabledViews: next, activeView: newActive));
                },
              );
            }),
          ]),

          // --- View selector display ---
          _SectionHeader('View Selector Style'),
          _SettingsCard(children: [
            ...SelectorMode.values.map((mode) {
              final label = switch (mode) {
                SelectorMode.iconAndWord => 'Icon and word (default)',
                SelectorMode.iconOnly => 'Icon only',
                SelectorMode.wordOnly => 'Word only',
              };
              final isSelected = settings.selectorMode == mode;
              return ListTile(
                title: Text(label),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: theme.colorScheme.primary)
                    : Icon(Icons.radio_button_unchecked,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                onTap: () =>
                    notifier.update((s) => s.copyWith(selectorMode: mode)),
              );
            }),
          ]),

          // --- Visual ---
          _SectionHeader('Appearance'),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('Dark mode'),
              value: settings.darkMode,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(darkMode: v)),
            ),
            ListTile(
              title: const Text('Color theme'),
              subtitle: Text(settings.colorTheme.label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: settings.colorTheme.barFillColor,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right,
                      color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                ],
              ),
              onTap: () => _showColorThemePicker(context, ref),
            ),
            ListTile(
              title: const Text('Font size'),
              subtitle: Slider(
                value: settings.fontSizeScale,
                min: 0.8,
                max: 1.6,
                divisions: 8,
                label: '${(settings.fontSizeScale * 100).round()}%',
                onChanged: (v) =>
                    notifier.update((s) => s.copyWith(fontSizeScale: v)),
              ),
            ),
          ]),

          // --- Child-accessible options ---
          _SectionHeader('Child Display Options'),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              'Allow the child to toggle these on the main screen.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('Start / End labels'),
              value: settings.caregiverAllowStartEnd,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(caregiverAllowStartEnd: v)),
            ),
            SwitchListTile(
              title: const Text('Countdown ("2h 14m left")'),
              value: settings.caregiverAllowCountdown,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(caregiverAllowCountdown: v)),
            ),
            SwitchListTile(
              title: const Text('Proportion ("about halfway")'),
              value: settings.caregiverAllowProportion,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(caregiverAllowProportion: v)),
            ),
            SwitchListTile(
              title: const Text('Event labels'),
              subtitle: const Text('Show labels on event markers'),
              value: settings.caregiverAllowEventLabels,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(caregiverAllowEventLabels: v)),
            ),
          ]),

          // --- Events ---
          _SectionHeader('Events (Time View)'),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              'Markers shown on the time bar for upcoming events.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          _SettingsCard(children: [
            SwitchListTile(
              title: const Text('Play chime at event time'),
              subtitle: const Text('Plays once when the app is open'),
              value: settings.eventChimesEnabled,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(eventChimesEnabled: v)),
            ),
          ]),
          const SizedBox(height: 8),
          if (settings.events.isNotEmpty) ...[
            _SettingsCard(children: [
              ...settings.events.map((event) => ListTile(
                    leading: Icon(Icons.flag_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                    title: Text(event.label),
                    subtitle: Text(event.time.format(context)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.4)),
                      onPressed: () => notifier.deleteEvent(event.id),
                    ),
                    onTap: () => _showEventDialog(context, ref, event: event),
                  )),
            ]),
            const SizedBox(height: 8),
          ],
          _SettingsCard(children: [
            ListTile(
              leading: Icon(Icons.add_circle_outline,
                  color: theme.colorScheme.primary),
              title: const Text('Add event'),
              onTap: () => _showEventDialog(context, ref),
            ),
          ]),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, WidgetRef ref,
      {AppEvent? event}) {
    final notifier = ref.read(settingsProvider.notifier);
    final labelController = TextEditingController(text: event?.label ?? '');
    TimeOfDay selectedTime = event?.time ?? TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(event == null ? 'Add event' : 'Edit event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (picked != null) setState(() => selectedTime = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final label = labelController.text.trim();
                if (label.isEmpty) return;
                if (event == null) {
                  notifier.addEvent(AppEvent(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    time: selectedTime,
                    label: label,
                  ));
                } else {
                  notifier.updateEvent(
                      event.copyWith(time: selectedTime, label: label));
                }
                Navigator.pop(ctx);
              },
              child: Text(event == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorThemePicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color Theme',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          ...ColorThemeType.values.map((ct) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                title: Text(ct.label),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ct.barFillColor,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                ),
                onTap: () {
                  notifier.update((s) => s.copyWith(colorTheme: ct));
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF252421) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _withDividers(children, theme.dividerColor),
      ),
    );
  }

  static List<Widget> _withDividers(List<Widget> items, Color dividerColor) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(
            height: 0.5, thickness: 0.5, indent: 16, color: dividerColor));
      }
    }
    return result;
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(time.format(context)),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

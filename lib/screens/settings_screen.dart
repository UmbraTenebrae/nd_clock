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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Time format ---
          _SectionHeader('Time Format'),
          SwitchListTile(
            title: const Text('24-hour time'),
            value: settings.use24Hour,
            onChanged: (v) => notifier.update((s) => s.copyWith(use24Hour: v)),
          ),

          // --- Custom time range ---
          _SectionHeader('Time View Range'),
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

          // --- Enabled views ---
          _SectionHeader('Available Views'),
          ...ViewType.values.map((view) {
            final enabled = settings.enabledViews.contains(view);
            return SwitchListTile(
              title: Text(view.label),
              value: enabled,
              onChanged: (v) {
                final next = List<ViewType>.from(settings.enabledViews);
                if (v) {
                  next.add(view);
                  // Preserve ordering
                  next.sort((a, b) =>
                      ViewType.values.indexOf(a) -
                      ViewType.values.indexOf(b));
                } else {
                  if (next.length <= 1) return; // must keep at least one
                  next.remove(view);
                }
                final newActive = next.contains(settings.activeView)
                    ? settings.activeView
                    : next.first;
                notifier.update((s) =>
                    s.copyWith(enabledViews: next, activeView: newActive));
              },
            );
          }),

          // --- View selector display ---
          _SectionHeader('View Selector Style'),
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
                      color: Theme.of(context).colorScheme.primary)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: () =>
                  notifier.update((s) => s.copyWith(selectorMode: mode)),
            );
          }),

          // --- Visual ---
          _SectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.darkMode,
            onChanged: (v) =>
                notifier.update((s) => s.copyWith(darkMode: v)),
          ),
          ListTile(
            title: const Text('Color theme'),
            subtitle: Text(settings.colorTheme.label),
            trailing: const Icon(Icons.chevron_right),
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

          // --- Child-accessible options ---
          _SectionHeader('Child Display Options'),
          const Text(
            'Allow the child to toggle these on the main screen.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Start / End labels'),
            value: settings.caregiverAllowStartEnd,
            onChanged: (v) =>
                notifier.update((s) => s.copyWith(caregiverAllowStartEnd: v)),
          ),
          SwitchListTile(
            title: const Text('Countdown ("2h 14m left")'),
            value: settings.caregiverAllowCountdown,
            onChanged: (v) => notifier
                .update((s) => s.copyWith(caregiverAllowCountdown: v)),
          ),
          SwitchListTile(
            title: const Text('Proportion ("about halfway")'),
            value: settings.caregiverAllowProportion,
            onChanged: (v) => notifier
                .update((s) => s.copyWith(caregiverAllowProportion: v)),
          ),
          SwitchListTile(
            title: const Text('Event labels'),
            subtitle: const Text('Show labels on event markers'),
            value: settings.caregiverAllowEventLabels,
            onChanged: (v) => notifier
                .update((s) => s.copyWith(caregiverAllowEventLabels: v)),
          ),

          // --- Events ---
          _SectionHeader('Events (Time View)'),
          const Text(
            'Markers shown on the time bar for upcoming events.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...settings.events.map((event) => ListTile(
                leading: const Icon(Icons.flag_rounded),
                title: Text(event.label),
                subtitle: Text(event.time.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => notifier.deleteEvent(event.id),
                ),
                onTap: () => _showEventDialog(context, ref, event: event),
              )),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add event'),
            onTap: () => _showEventDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, WidgetRef ref,
      {AppEvent? event}) {
    final notifier = ref.read(settingsProvider.notifier);
    final labelController =
        TextEditingController(text: event?.label ?? '');
    TimeOfDay selectedTime =
        event?.time ?? TimeOfDay.now();

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
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
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
        children: ColorThemeType.values.map((theme) {
          return ListTile(
            title: Text(theme.label),
            leading: CircleAvatar(
              backgroundColor: theme.barFillColor,
              child: Icon(Icons.check,
                  color: theme.backgroundColor, size: 16),
            ),
            onTap: () {
              notifier.update((s) => s.copyWith(colorTheme: theme));
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
      ),
    );
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

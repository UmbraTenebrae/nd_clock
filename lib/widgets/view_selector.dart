import 'package:flutter/material.dart';
import '../models/view_type.dart';
import '../models/selector_mode.dart';
import '../models/app_settings.dart';

/// Maps each ViewType to a Material icon.
IconData _iconFor(ViewType view) {
  switch (view) {
    case ViewType.time:
      return Icons.access_time_rounded;
    case ViewType.day:
      return Icons.wb_sunny_rounded;
    case ViewType.week:
      return Icons.view_week_rounded;
    case ViewType.month:
      return Icons.calendar_month_rounded;
    case ViewType.year:
      return Icons.calendar_today_rounded;
  }
}

class ViewSelector extends StatelessWidget {
  final AppSettings settings;
  final void Function(ViewType) onSelect;

  const ViewSelector({
    super.key,
    required this.settings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.primary;
    final bg = theme.scaffoldBackgroundColor;
    final enabled = settings.enabledViews;
    final active = settings.activeView;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: enabled.map((view) {
        final isActive = view == active;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSelect(view),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? fg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fg, width: isActive ? 0 : 1.5),
                ),
                child: _buildContent(view, isActive, fg, bg),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent(
      ViewType view, bool isActive, Color fg, Color bg) {
    final color = isActive ? bg : fg;
    final icon = Icon(_iconFor(view), color: color, size: 28);
    final label = Text(
      view.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );

    switch (settings.selectorMode) {
      case SelectorMode.iconOnly:
        return icon;
      case SelectorMode.wordOnly:
        return label;
      case SelectorMode.iconAndWord:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [icon, const SizedBox(height: 4), label],
        );
    }
  }
}

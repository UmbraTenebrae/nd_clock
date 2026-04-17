import 'package:flutter/material.dart';
import '../models/view_type.dart';
import '../models/selector_mode.dart';
import '../models/app_settings.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final enabled = settings.enabledViews;
    final active = settings.activeView;

    final trayColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final selectedBg = isDark ? const Color(0xFF2E2C2A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trayColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: enabled.map((view) {
          final isActive = view == active;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(view),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: isActive
                    ? BoxDecoration(
                        color: selectedBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.30 : 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                child: _buildContent(view, isActive, fg),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(ViewType view, bool isActive, Color fg) {
    final color = isActive ? fg : fg.withValues(alpha: 0.45);
    final icon = Icon(view.icon, color: color, size: 26);
    final label = Text(
      view.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
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
          children: [icon, const SizedBox(height: 3), label],
        );
    }
  }
}

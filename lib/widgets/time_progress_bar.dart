import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../models/color_theme_type.dart';

class TimeProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final AppSettings settings;

  const TimeProgressBar({
    super.key,
    required this.progress,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final fill = AppTheme.barColor(settings);
    final track = AppTheme.trackColor(settings);
    final isHighContrast =
        settings.colorTheme == ColorThemeType.highContrast;
    final barHeight = (isHighContrast ? 48.0 : 36.0) * settings.fontSizeScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(barHeight / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

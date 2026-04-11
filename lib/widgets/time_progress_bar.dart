import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../models/app_event.dart';
import '../models/color_theme_type.dart';
import '../models/view_type.dart';
import '../utils/time_utils.dart';

// Vertical space reserved above and below the bar for event labels.
const double _labelZone = 26.0;
// How far the tick extends past the top/bottom edge of the bar.
const double _tickOverflow = 7.0;
// Fixed width given to each label Positioned so Align can centre the text.
const double _estimatedLabelWidth = 80.0;

class TimeProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final AppSettings settings;
  final DateTime now;

  const TimeProgressBar({
    super.key,
    required this.progress,
    required this.settings,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final fill = AppTheme.barFillColor(settings);
    final track = AppTheme.trackColor(settings);
    final isHighContrast = settings.colorTheme == ColorThemeType.highContrast;
    final barHeight = (isHighContrast ? 48.0 : 36.0) * settings.fontSizeScale;

    final showMarkers = settings.activeView == ViewType.time &&
        settings.events.isNotEmpty;
    final showLabels = showMarkers &&
        settings.caregiverAllowEventLabels &&
        settings.childShowEventLabels;

    // Total stack height: label zone top + bar + label zone bottom.
    // If no labels needed, just bar + tick overflow on each side.
    final double topSpace = showLabels ? _labelZone : _tickOverflow;
    final double bottomSpace = showLabels ? _labelZone : _tickOverflow;
    final double totalHeight = topSpace + barHeight + bottomSpace;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        // Compute marker positions and label placements before building.
        final markers = showMarkers
            ? _buildMarkerData(barWidth, showLabels)
            : <_MarkerData>[];

        // When labels are shown the tick must not enter the label zone.
        // Leave 3 px of breathing room between the label bottom and tick top.
        const double labelGap = 3.0;
        final double tickTop = showLabels
            ? topSpace + labelGap
            : topSpace - _tickOverflow;
        final double tickBottom = showLabels
            ? bottomSpace + labelGap
            : bottomSpace - _tickOverflow;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Progress bar ──────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: topSpace,
                height: barHeight,
                child: Container(
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
                ),
              ),

              // ── Event markers ─────────────────────────────────────────
              for (final m in markers) ...[
                // Tick line — extends from just inside the bar (with label gap
                // above/below) or overflows slightly when no labels are shown.
                Positioned(
                  left: (m.x - 1.5).clamp(0, barWidth - 3),
                  top: tickTop,
                  bottom: tickBottom,
                  width: 3,
                  child: Container(color: m.color),
                ),

                // Label — above or below the bar.
                if (m.label != null)
                  Positioned(
                    left: _clampLabelLeft(m.x, barWidth),
                    top: m.above ? 0 : null,
                    bottom: m.above ? null : 0,
                    width: _estimatedLabelWidth,
                    height: _labelZone,
                    child: Align(
                      alignment: m.above
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      child: Text(
                        m.label!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: m.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Converts events to positioned marker data, assigning above/below
  /// alternately for markers whose labels would overlap (within 80px).
  List<_MarkerData> _buildMarkerData(double barWidth, bool showLabels) {
    // Upcoming events use a theme-specific accent color distinct from the bar fill.
    final futureColor = settings.darkMode
        ? settings.colorTheme.eventColorDark
        : settings.colorTheme.eventColor;
    // Past events use a neutral gray.
    final pastColor = settings.darkMode
        ? Colors.grey.shade500
        : Colors.grey.shade400;

    // Resolve fraction for each event; drop those outside the range.
    final resolved = <({AppEvent event, double fraction})>[];
    for (final event in settings.events) {
      final f = eventFractionFor(event, settings);
      if (f != null) resolved.add((event: event, fraction: f));
    }
    // Sort left-to-right.
    resolved.sort((a, b) => a.fraction.compareTo(b.fraction));

    final markers = <_MarkerData>[];
    bool lastAbove = false; // will be flipped for the first event → above

    for (int i = 0; i < resolved.length; i++) {
      final r = resolved[i];
      final x = r.fraction * barWidth;
      final isPast = _isPast(r.event);
      final color = isPast ? pastColor : futureColor;

      // Determine above/below: flip if this marker is within 80px of the
      // previous one (labels would overlap); otherwise default to above.
      bool above;
      if (i == 0) {
        above = true;
      } else {
        final prevX = resolved[i - 1].fraction * barWidth;
        above = (x - prevX) < 80 ? !lastAbove : true;
      }
      lastAbove = above;

      markers.add(_MarkerData(
        x: x,
        color: color,
        label: (showLabels && !isPast) ? r.event.label : null,
        above: above,
      ));
    }
    return markers;
  }

  bool _isPast(AppEvent event) {
    final eventMinutes = event.time.hour * 60 + event.time.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes >= eventMinutes;
  }

  /// Clamps the label's left edge so it doesn't run off either side.
  double _clampLabelLeft(double centerX, double barWidth) {
    final left = centerX - _estimatedLabelWidth / 2;
    return left.clamp(0, barWidth - _estimatedLabelWidth);
  }
}

class _MarkerData {
  final double x;
  final Color color;
  final String? label;
  final bool above;

  const _MarkerData({
    required this.x,
    required this.color,
    required this.label,
    required this.above,
  });
}

import 'package:flutter/material.dart';

enum ViewType { time, day, week, month, year }

extension ViewTypeLabel on ViewType {
  String get label {
    switch (this) {
      case ViewType.time:
        return 'Time';
      case ViewType.day:
        return 'Day';
      case ViewType.week:
        return 'Week';
      case ViewType.month:
        return 'Month';
      case ViewType.year:
        return 'Year';
    }
  }

  IconData get icon {
    switch (this) {
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
}

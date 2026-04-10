import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/view_type.dart';

/// Returns a progress value in [0.0, 1.0] for the given [view] at [now].
double progressFor(ViewType view, DateTime now, AppSettings settings) {
  switch (view) {
    case ViewType.time:
      return _timeViewProgress(now, settings);
    case ViewType.day:
      return _dayProgress(now);
    case ViewType.week:
      return _weekProgress(now);
    case ViewType.month:
      return _monthProgress(now);
    case ViewType.year:
      return _yearProgress(now);
  }
}

double _timeViewProgress(DateTime now, AppSettings settings) {
  final TimeOfDay start;
  final TimeOfDay end;

  if (settings.useCustomRange) {
    start = settings.customStartTime;
    end = settings.customEndTime;
  } else if (settings.use24Hour) {
    start = const TimeOfDay(hour: 0, minute: 0);
    end = const TimeOfDay(hour: 23, minute: 59);
  } else {
    start = const TimeOfDay(hour: 0, minute: 0);
    end = const TimeOfDay(hour: 23, minute: 59);
  }

  final startSeconds = start.hour * 3600 + start.minute * 60;
  final endSeconds = end.hour * 3600 + end.minute * 60;
  final nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;

  if (endSeconds <= startSeconds) return 0.0; // misconfigured range
  final progress =
      (nowSeconds - startSeconds) / (endSeconds - startSeconds);
  return progress.clamp(0.0, 1.0);
}

double _dayProgress(DateTime now) {
  final secondsInDay = 24 * 3600;
  final elapsed = now.hour * 3600 + now.minute * 60 + now.second;
  return elapsed / secondsInDay;
}

double _weekProgress(DateTime now) {
  // Week starts Sunday (weekday == 7 in Dart, or use 0-based conversion)
  // Dart: Monday=1, Tuesday=2, ..., Sunday=7
  final dayIndex = now.weekday % 7; // Sunday=0, Monday=1, ..., Saturday=6
  final secondsInWeek = 7 * 24 * 3600;
  final elapsed =
      dayIndex * 24 * 3600 + now.hour * 3600 + now.minute * 60 + now.second;
  return elapsed / secondsInWeek;
}

double _monthProgress(DateTime now) {
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  // Use fractional day: (day - 1 + fraction of current day) / daysInMonth
  final dayFraction =
      (now.hour * 3600 + now.minute * 60 + now.second) / (24 * 3600);
  return ((now.day - 1) + dayFraction) / daysInMonth;
}

double _yearProgress(DateTime now) {
  final startOfYear = DateTime(now.year, 1, 1);
  final startOfNextYear = DateTime(now.year + 1, 1, 1);
  final daysInYear =
      startOfNextYear.difference(startOfYear).inSeconds.toDouble();
  final elapsed = now.difference(startOfYear).inSeconds.toDouble();
  return (elapsed / daysInYear).clamp(0.0, 1.0);
}

/// The large display string shown above the bar — contextual to the active view.
///
/// - Time / Day → current time ("3:45 PM" / "15:45")
/// - Week       → current day name ("Wednesday")
/// - Month      → month + day ("April 10")
/// - Year       → current month name ("April")
String currentDisplayLabel(ViewType view, DateTime now, AppSettings settings) {
  switch (view) {
    case ViewType.time:
    case ViewType.day:
      return _formatTime(now, settings.use24Hour);
    case ViewType.week:
      return _weekdayName(now.weekday);
    case ViewType.month:
      return '${_monthName(now.month)} ${now.day}';
    case ViewType.year:
      return _monthName(now.month);
  }
}

const _weekdays = [
  '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

const _months = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

String _weekdayName(int weekday) => _weekdays[weekday];
String _monthName(int month) => _months[month];

String _formatTime(DateTime now, bool use24Hour) {
  if (use24Hour) {
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  final period = now.hour < 12 ? 'AM' : 'PM';
  final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
  return '$hour:${now.minute.toString().padLeft(2, '0')} $period';
}

/// Human-readable start label for each view.
String startLabelFor(ViewType view, DateTime now, AppSettings settings) {
  switch (view) {
    case ViewType.time:
      final t = settings.useCustomRange
          ? settings.customStartTime
          : const TimeOfDay(hour: 0, minute: 0);
      return _formatTimeOfDay(t, settings.use24Hour);
    case ViewType.day:
      return '12:00 AM';
    case ViewType.week:
      return 'Sun';
    case ViewType.month:
      return '1';
    case ViewType.year:
      return 'Jan';
  }
}

/// Human-readable end label for each view.
String endLabelFor(ViewType view, DateTime now, AppSettings settings) {
  switch (view) {
    case ViewType.time:
      final t = settings.useCustomRange
          ? settings.customEndTime
          : const TimeOfDay(hour: 23, minute: 59);
      return _formatTimeOfDay(t, settings.use24Hour);
    case ViewType.day:
      return '11:59 PM';
    case ViewType.week:
      return 'Sat';
    case ViewType.month:
      return '${DateUtils.getDaysInMonth(now.year, now.month)}';
    case ViewType.year:
      return 'Dec';
  }
}

String _formatTimeOfDay(TimeOfDay t, bool use24Hour) {
  if (use24Hour) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
  final period = t.hour < 12 ? 'AM' : 'PM';
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$hour:${t.minute.toString().padLeft(2, '0')} $period';
}

/// Returns a countdown string appropriate for the active view's scale.
///
/// - Time / Day → "2h 14m left"
/// - Week       → "3 days left" (or hours if < 1 day remains)
/// - Month      → "18 days left" (or hours if < 1 day remains)
/// - Year       → "8 months left" → "3 weeks left" → "5 days left"
String countdownLabel(ViewType view, DateTime now, AppSettings settings) {
  final progress = progressFor(view, now, settings);
  final remaining = 1.0 - progress;
  if (remaining <= 0) return 'Done';

  final totalSeconds = _totalSecondsFor(view, now, settings);
  final remainingSeconds = (totalSeconds * remaining).round();

  switch (view) {
    case ViewType.time:
    case ViewType.day:
      return _hoursMinutesLeft(remainingSeconds);

    case ViewType.week:
    case ViewType.month:
      final days = remainingSeconds ~/ 86400;
      if (days >= 1) return days == 1 ? '1 day left' : '$days days left';
      return _hoursMinutesLeft(remainingSeconds);

    case ViewType.year:
      final days = remainingSeconds ~/ 86400;
      final weeks = days ~/ 7;
      final months = _remainingWholeMonths(now);
      if (months >= 2) return '$months months left';
      if (weeks >= 2) return '$weeks weeks left';
      if (days >= 1) return days == 1 ? '1 day left' : '$days days left';
      return _hoursMinutesLeft(remainingSeconds);
  }
}

String _hoursMinutesLeft(int remainingSeconds) {
  final hours = remainingSeconds ~/ 3600;
  final minutes = (remainingSeconds % 3600) ~/ 60;
  if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m left';
  if (hours > 0) return '${hours}h left';
  if (minutes > 0) return '${minutes}m left';
  return 'Less than a minute left';
}

/// Counts whole calendar months remaining in the year after the current one.
int _remainingWholeMonths(DateTime now) {
  return 12 - now.month;
}

/// Returns a plain-language proportion string like "about halfway".
String proportionLabel(double progress) {
  if (progress <= 0.02) return 'Just started';
  if (progress < 0.15) return 'Just beginning';
  if (progress < 0.35) return 'About a quarter done';
  if (progress < 0.45) return 'Getting close to halfway';
  if (progress < 0.55) return 'About halfway';
  if (progress < 0.65) return 'A little past halfway';
  if (progress < 0.80) return 'About three quarters done';
  if (progress < 0.92) return 'Almost done';
  if (progress < 1.0) return 'Nearly finished';
  return 'Done';
}

int _totalSecondsFor(ViewType view, DateTime now, AppSettings settings) {
  switch (view) {
    case ViewType.time:
      final start = settings.useCustomRange
          ? settings.customStartTime
          : const TimeOfDay(hour: 0, minute: 0);
      final end = settings.useCustomRange
          ? settings.customEndTime
          : const TimeOfDay(hour: 23, minute: 59);
      return (end.hour * 3600 + end.minute * 60) -
          (start.hour * 3600 + start.minute * 60);
    case ViewType.day:
      return 24 * 3600;
    case ViewType.week:
      return 7 * 24 * 3600;
    case ViewType.month:
      return DateUtils.getDaysInMonth(now.year, now.month) * 24 * 3600;
    case ViewType.year:
      final daysInYear =
          DateTime(now.year + 1, 1, 1).difference(DateTime(now.year, 1, 1)).inDays;
      return daysInYear * 24 * 3600;
  }
}

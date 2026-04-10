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
}

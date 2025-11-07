enum Shift { morning, afternoon, evening, night }

extension ShiftExtension on Shift {
  String get timeRange {
    switch (this) {
      case Shift.morning:
        return '8:00 - 12:00';
      case Shift.afternoon:
        return '12:00 - 16:00';
      case Shift.evening:
        return '16:00 - 20:00';
      case Shift.night:
        return '20:00 - 8:00';
    }
  }

  String get displayName {
    switch (this) {
      case Shift.morning:
        return 'Morning (8:00 - 12:00)';
      case Shift.afternoon:
        return 'Afternoon (12:00 - 16:00)';
      case Shift.evening:
        return 'Evening (16:00 - 20:00)';
      case Shift.night:
        return 'Night (20:00 - 8:00)';
    }
  }
}

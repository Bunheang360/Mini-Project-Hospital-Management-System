enum Shift {
  morning,
  afternoon,
  evening,
  night;

  String get displayName {
    switch (this) {
      case Shift.morning:
        return 'Morning (6:00 AM - 2:00 PM)';
      case Shift.afternoon:
        return 'Afternoon (2:00 PM - 10:00 PM)';
      case Shift.evening:
        return 'Evening (6:00 PM - 2:00 AM)';
      case Shift.night:
        return 'Night (10:00 PM - 6:00 AM)';
    }
  }

  static Shift fromString(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return Shift.morning;
      case 'afternoon':
        return Shift.afternoon;
      case 'evening':
        return Shift.evening;
      case 'night':
        return Shift.night;
      default:
        throw ArgumentError('Invalid shift: $shift');
    }
  }
}

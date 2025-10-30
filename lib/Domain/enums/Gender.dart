enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static Gender fromString(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'm':
        return Gender.male;
      case 'female':
      case 'f':
        return Gender.female;
      case 'other':
      case 'o':
        return Gender.other;
      default:
        throw ArgumentError('Invalid gender: $gender');
    }
  }
}
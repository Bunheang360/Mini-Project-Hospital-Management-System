import '../enums/gender.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final String phoneNumber;
  final String address;
  final String? medicalHistory;
  final DateTime registrationDate;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    this.medicalHistory,
    required this.registrationDate,
  });

  // Validation methods
  bool isValidName() {
    return name.isNotEmpty && name.length >= 2;
  }

  bool isValidAge() {
    return age > 0 && age <= 150;
  }

  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^\d{8,15}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  bool isValidAddress() {
    return address.isNotEmpty && address.length >= 5;
  }

  String getDisplayInfo() {
    return '$name (${gender.displayName}, $age years) - $phoneNumber';
  }

  // Helper method to check if patient is a kid
  bool isKid() {
    return age < 18;
  }

  // Helper method to check if patient is elderly
  bool isElderly() {
    return age >= 65;
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $name, age: $age, '
        'gender: ${gender.displayName}, phone: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
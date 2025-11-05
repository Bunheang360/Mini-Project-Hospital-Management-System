import '../enums/gender.dart';
import '../enums/shift.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String department;
  final Shift shift;
  final String phoneNumber;
  final String email;
  final Gender gender;
  final int yearsOfExperience;
  final DateTime createdAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.department,
    required this.shift,
    required this.phoneNumber,
    required this.email,
    required this.gender,
    required this.yearsOfExperience,
    required this.createdAt,
  });

  // Validation methods
  bool isValidName() {
    return name.isNotEmpty && name.length >= 2;
  }

  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^\d{8,15}$');
    return phoneRegex.hasMatch(
      phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''),
    );
  }

  bool isValidExperience() {
    return yearsOfExperience >= 0 && yearsOfExperience <= 60;
  }

  bool isValidDepartment() {
    return department.isNotEmpty;
  }

  bool isValidShift() {
    return true; // Always valid since it's an enum
  }

  String getDisplayInfo() {
    return 'Dr. $name - $specialization, $department (${shift.displayName}) (${yearsOfExperience} years exp.)';
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialization: $specialization, '
        'department: $department, shift: ${shift.displayName}, '
        'gender: ${gender.displayName}, experience: $yearsOfExperience years)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

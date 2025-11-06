import 'user.dart';
import '../enums/user_role.dart';
import '../enums/gender.dart';

class Doctor extends User {
  final String specialization;
  final String department;
  final String
  shift; // e.g., "Morning (8:00-16:00)", "Evening (16:00-24:00)", "Night (24:00-8:00)"

  Doctor({
    required super.id,
    required super.username,
    required super.password,
    required super.name,
    required super.gender,
    required super.phone,
    required super.email,
    required this.specialization,
    required this.department,
    this.shift = 'Morning (8:00-16:00)', // Default shift
  }) : super(role: UserRole.doctor);

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      email: json['email'],
      specialization: json['specialization'],
      department: json['department'] ?? json['licenseNumber'] ?? 'N/A',
      shift: json['shift'] ?? 'Morning (8:00-16:00)',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'gender': gender.name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'specialization': specialization,
      'department': department,
      'shift': shift,
    };
  }

  @override
  void displayInfo() {
    super.displayInfo();
    print('Specialization: $specialization');
    print('Department: $department');
    print('Shift: $shift');
  }
}

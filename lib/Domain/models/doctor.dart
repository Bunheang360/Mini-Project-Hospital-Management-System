import 'user.dart';
import '../enums/user_role.dart';
import '../enums/gender.dart';
import '../enums/shift.dart';

class Doctor extends User {
  final String specialization;
  final String department;
  final Shift shift;

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
    this.shift = Shift.morning,
  }) : super(role: UserRole.doctor);

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Validate required fields exist
    if (json['phone'] == null && json['phoneNumber'] == null) {
      throw ArgumentError('Phone number is required');
    }
    
    if (json['department'] == null && json['licenseNumber'] == null) {
      throw ArgumentError('Department is required');
    }

    return Doctor(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      phone: json['phone'] ?? json['phoneNumber']!,
      email: json['email'],
      specialization: json['specialization'],
      department: json['department'] ?? json['licenseNumber']!,
      shift: Shift.values.firstWhere(
        (e) => e.name == json['shift'],
        orElse: () => Shift.morning,
      ),
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
      'shift': shift.name,
    };
  }

  @override
  void displayInfo() {
    super.displayInfo();
    print('Specialization: $specialization');
    print('Department: $department');
    print('Shift: ${shift.displayName}');
  }
}
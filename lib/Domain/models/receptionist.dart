import 'user.dart';
import '../enums/user_role.dart';
import '../enums/gender.dart';
import '../enums/shift.dart';

class Receptionist extends User {
  final Shift shift;

  Receptionist({
    required super.id,
    required super.username,
    required super.password,
    required super.name,
    required super.gender,
    required super.phone,
    required super.email,
    required this.shift,
  }) : super(role: UserRole.receptionist);

  factory Receptionist.fromJson(Map<String, dynamic> json) {
    return Receptionist(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      phone: json['phone'],
      email: json['email'],
      shift: Shift.values.firstWhere((e) => e.name == json['shift']),
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
      'shift': shift.name,
    };
  }

  @override
  void displayInfo() {
    super.displayInfo();
    print('Shift: ${shift.displayName}');
  }
}
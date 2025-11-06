import '../enums/user_role.dart';
import '../enums/gender.dart';

abstract class User {
  final String id;
  final String username;
  String password;
  final String name;
  final Gender gender;
  final String phone;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.gender,
    required this.phone,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson();

  void displayInfo() {
    print('ID: $id');
    print('Username: $username');
    print('Name: $name');
    print('Gender: ${gender.name}');
    print('Phone: $phone');
    print('Email: $email');
    print('Role: ${role.name}');
  }
}

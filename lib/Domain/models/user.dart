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

  // Validation methods
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhone() {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidPassword() {
    return password.length >= 6;
  }

  bool isValidUsername() {
    return username.length >= 3 && !username.contains(' ');
  }

  bool isValidId() {
    return id.isNotEmpty && id.length >= 3;
  }

  bool isValidName() {
    return name.isNotEmpty && name.length >= 2;
  }

  bool validate() {
    return isValidId() &&
        isValidUsername() &&
        isValidPassword() &&
        isValidName() &&
        isValidEmail() &&
        isValidPhone();
  }

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
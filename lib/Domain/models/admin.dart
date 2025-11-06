import 'user.dart';
import '../enums/user_role.dart';
import '../enums/gender.dart';

class Admin extends User {
  Admin({
    required super.id,
    required super.username,
    required super.password,
    required super.name,
    required super.gender,
    required super.phone,
    required super.email,
  }) : super(role: UserRole.admin);

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      phone: json['phone'],
      email: json['email'],
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
    };
  }
}

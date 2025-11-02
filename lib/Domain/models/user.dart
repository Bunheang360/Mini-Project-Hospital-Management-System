import '../enums/user_role.dart';

abstract class User {
  final String id;
  final String username;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  // Validation methods
  bool validateCredentials(String inputUsername, String inputPassword) {
    return username == inputUsername && password == inputPassword;
  }

  bool isValidUsername() {
    return username.isNotEmpty && username.length >= 3;
  }

  bool isValidPassword() {
    return password.isNotEmpty && password.length >= 6;
  }

  // Abstract method - polymorphism (each subclass implements differently)
  String getPermissions();

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: ${role.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
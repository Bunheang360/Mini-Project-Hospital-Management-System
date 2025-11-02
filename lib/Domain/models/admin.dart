import 'user.dart';
import '../enums/user_role.dart';

class Admin extends User {
  final String fullName;
  final String email;

  Admin({
    required super.id,
    required super.username,
    required super.password,
    required super.createdAt,
    required this.fullName,
    required this.email,
  }) : super(role: UserRole.admin);

  // Polymorphic implementation
  @override
  String getPermissions() {
    return 'Full Access: Manage Receptionists, Doctors, Rooms, Patients, Appointments';
  }

  // Admin-specific validation
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  String toString() {
    return 'Admin(id: $id, username: $username, name: $fullName, email: $email)';
  }
}
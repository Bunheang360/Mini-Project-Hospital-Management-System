import 'User.dart';
import '../enums/UserRole.dart';

class Receptionist extends User {
  final String fullName;
  final String phoneNumber;
  final String createdBy; // Admin ID who created this receptionist

  Receptionist({
    required super.id,
    required super.username,
    required super.password,
    required super.createdAt,
    required this.fullName,
    required this.phoneNumber,
    required this.createdBy,
  }) : super(role: UserRole.receptionist);

  // Polymorphic implementation
  @override
  String getPermissions() {
    return 'Limited Access: Manage Patients and Appointments only';
  }

  // Receptionist-specific validation
  bool isValidPhoneNumber() {
    // Basic phone validation (digits only, 8-15 chars)
    final phoneRegex = RegExp(r'^\d{8,15}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  @override
  String toString() {
    return 'Receptionist(id: $id, username: $username, name: $fullName, phone: $phoneNumber)';
  }
}
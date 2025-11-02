import 'user.dart';
import '../enums/user_role.dart';

class DoctorUser extends User {
  final String doctorId; // Reference to the Doctor entity
  final String fullName;

  DoctorUser({
    required super.id,
    required super.username,
    required super.password,
    required super.createdAt,
    required this.doctorId,
    required this.fullName,
  }) : super(role: UserRole.doctor);

  // Polymorphic implementation
  @override
  String getPermissions() {
    return 'Doctor Access: View own appointments, Update appointment status, View patient details';
  }

  @override
  String toString() {
    return 'DoctorUser(id: $id, username: $username, name: $fullName, doctorId: $doctorId)';
  }
}

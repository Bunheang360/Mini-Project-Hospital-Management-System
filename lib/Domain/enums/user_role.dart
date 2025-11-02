enum UserRole {
  admin,
  receptionist,
  doctor;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.doctor:
        return 'Doctor';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'receptionist':
        return UserRole.receptionist;
      case 'doctor':
        return UserRole.doctor;
      default:
        throw ArgumentError('Invalid user role: $role');
    }
  }
}

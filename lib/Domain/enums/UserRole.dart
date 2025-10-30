enum UserRole {
  admin,
  receptionist;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.receptionist:
        return 'Receptionist';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'receptionist':
        return UserRole.receptionist;
      default:
        throw ArgumentError('Invalid user role: $role');
    }
  }
}
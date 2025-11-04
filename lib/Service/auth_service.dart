import '../Domain/models/user.dart';
import '../Domain/models/admin.dart';
import '../Domain/enums/user_role.dart';
import '../Data/Repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  User? _currentUser;
  bool _initialized = false;

  AuthService(this._userRepository);

  // Initialize and create default admin if no users exist
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final users = await _userRepository.getAll();
      if (users.isEmpty) {
        final defaultAdmin = Admin(
          id: 'admin001',
          username: 'admin',
          password: 'admin123',
          createdAt: DateTime.now(),
          fullName: 'System Administrator',
          email: 'admin@hospital.com',
        );
        await _userRepository.save(defaultAdmin);
        print('\nDefault admin account created!');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('   Username: admin');
        print('   Password: admin123');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('Please change the password after first login.\n');
      }
      _initialized = true;
    } catch (e) {
      print('Error initializing default admin: $e');
    }
  }

  // Get current logged-in user
  User? get currentUser => _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Check if current user is admin
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // Check if current user is receptionist
  bool get isReceptionist => _currentUser?.role == UserRole.receptionist;

  // Check if current user is doctor
  bool get isDoctor => _currentUser?.role == UserRole.doctor;

  // Login with username and password
  Future<User?> login(String username, String password) async {
    // Validate input
    if (username.isEmpty || password.isEmpty) {
      throw ArgumentError('Username and password cannot be empty');
    }

    // Get user by username
    final user = await _userRepository.getByUsername(username);

    if (user == null) {
      throw Exception('User not found');
    }

    // Validate credentials
    if (!user.validateCredentials(username, password)) {
      throw Exception('Invalid credentials');
    }

    // Set current user
    _currentUser = user;
    return user;
  }

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    return !(await _userRepository.usernameExists(username));
  }

  // Validate user permissions for specific actions
  bool canManageReceptionists() {
    return isAdmin;
  }

  bool canManageDoctors() {
    return isAdmin;
  }

  bool canManageRooms() {
    return isAdmin;
  }

  bool canManagePatients() {
    return isAdmin || isReceptionist;
  }

  bool canManageAppointments() {
    return isAdmin || isReceptionist;
  }

  bool canViewOwnAppointments() {
    return isDoctor;
  }

  bool canUpdateAppointmentStatus() {
    return isDoctor || isAdmin || isReceptionist;
  }

  bool canViewPatientDetails() {
    return isDoctor || isAdmin || isReceptionist;
  }

  // Get permissions description for current user
  String getCurrentUserPermissions() {
    if (_currentUser == null) {
      return 'No user logged in';
    }
    return _currentUser!.getPermissions();
  }
}

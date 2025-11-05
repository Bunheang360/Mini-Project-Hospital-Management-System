import '../Domain/models/user.dart';
import '../Domain/models/admin.dart';
import '../Domain/models/receptionist.dart';
import '../Domain/models/doctor_user.dart';
import '../Domain/enums/shift.dart';
import '../Data/Repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  // Generate unique ID
  String _generateId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Create new Admin
  Future<Admin> createAdmin({
    required String username,
    required String password,
    required String fullName,
    required String email,
  }) async {
    // Validate inputs
    if (username.isEmpty || username.length < 3) {
      throw ArgumentError('Username must be at least 3 characters');
    }

    if (password.isEmpty || password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    if (fullName.isEmpty) {
      throw ArgumentError('Full name cannot be empty');
    }

    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    // Check if username already exists
    if (await _userRepository.usernameExists(username)) {
      throw Exception('Username already exists');
    }

    // Create admin
    final admin = Admin(
      id: _generateId(),
      username: username,
      password: password,
      createdAt: DateTime.now(),
      fullName: fullName,
      email: email,
    );

    // Validate email
    if (!admin.isValidEmail()) {
      throw ArgumentError('Invalid email format');
    }

    // Save to repository
    await _userRepository.save(admin);

    return admin;
  }

  // Create new Receptionist
  Future<Receptionist> createReceptionist({
    required String username,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String createdByAdminId,
    required Shift shift,
  }) async {
    // Validate inputs
    if (username.isEmpty || username.length < 3) {
      throw ArgumentError('Username must be at least 3 characters');
    }

    if (password.isEmpty || password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    if (fullName.isEmpty) {
      throw ArgumentError('Full name cannot be empty');
    }

    if (phoneNumber.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    // Check if username already exists
    if (await _userRepository.usernameExists(username)) {
      throw Exception('Username already exists');
    }

    // Create receptionist
    final receptionist = Receptionist(
      id: _generateId(),
      username: username,
      password: password,
      createdAt: DateTime.now(),
      fullName: fullName,
      phoneNumber: phoneNumber,
      createdBy: createdByAdminId,
      shift: shift,
    );

    // Validate phone number
    if (!receptionist.isValidPhoneNumber()) {
      throw ArgumentError('Invalid phone number format');
    }

    // Save to repository
    await _userRepository.save(receptionist);

    return receptionist;
  }

  // Create new Doctor User
  Future<DoctorUser> createDoctorUser({
    required String username,
    required String password,
    required String fullName,
    required String doctorId,
  }) async {
    // Validate inputs
    if (username.isEmpty || username.length < 3) {
      throw ArgumentError('Username must be at least 3 characters');
    }

    if (password.isEmpty || password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    if (fullName.isEmpty) {
      throw ArgumentError('Full name cannot be empty');
    }

    if (doctorId.isEmpty) {
      throw ArgumentError('Doctor ID cannot be empty');
    }

    // Check if username already exists
    if (await _userRepository.usernameExists(username)) {
      throw Exception('Username already exists');
    }

    // Create doctor user
    final doctorUser = DoctorUser(
      id: _generateId(),
      username: username,
      password: password,
      createdAt: DateTime.now(),
      fullName: fullName,
      doctorId: doctorId,
    );

    // Save to repository
    await _userRepository.save(doctorUser);

    return doctorUser;
  }

  // Get all users
  Future<List<User>> getAllUsers() {
    return _userRepository.getAll();
  }

  // Get all receptionists
  Future<List<Receptionist>> getAllReceptionists() async {
    final users = await _userRepository.getAll();
    return users.whereType<Receptionist>().toList();
  }

  // Get all admins
  Future<List<Admin>> getAllAdmins() async {
    final users = await _userRepository.getAll();
    return users.whereType<Admin>().toList();
  }

  // Get all doctor users
  Future<List<DoctorUser>> getAllDoctorUsers() async {
    final users = await _userRepository.getAll();
    return users.whereType<DoctorUser>().toList();
  }

  // Get user by ID
  Future<User?> getUserById(String id) {
    return _userRepository.getById(id);
  }

  // Update receptionist
  Future<void> updateReceptionist(Receptionist receptionist) async {
    // Validate
    if (!receptionist.isValidUsername()) {
      throw ArgumentError('Invalid username');
    }

    if (!receptionist.isValidPassword()) {
      throw ArgumentError('Invalid password');
    }

    if (!receptionist.isValidPhoneNumber()) {
      throw ArgumentError('Invalid phone number');
    }

    return _userRepository.save(receptionist);
  }

  // Delete receptionist
  Future<bool> deleteReceptionist(String id) async {
    // Check if user exists and is a receptionist
    final user = await _userRepository.getById(id);

    if (user == null) {
      throw Exception('User not found');
    }

    if (user is! Receptionist) {
      throw Exception('User is not a receptionist');
    }

    return _userRepository.delete(id);
  }

  // Get receptionist count
  Future<int> getReceptionistCount() async {
    final receptionists = await getAllReceptionists();
    return receptionists.length;
  }
}

import '../models/doctor.dart';
import '../enums/gender.dart';
import '../../Data/Repositories/doctor_repository.dart';

class DoctorService {
  final DoctorRepository _doctorRepository;

  DoctorService(this._doctorRepository);

  // Generate unique ID
  String _generateId() {
    return 'doc_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Create new doctor
  Future<Doctor> createDoctor({
    required String name,
    required String specialization,
    required String department,
    required String shift,
    required String phoneNumber,
    required String email,
    required Gender gender,
    required int yearsOfExperience,
  }) async {
    // Validate inputs
    if (name.isEmpty || name.length < 2) {
      throw ArgumentError('Name must be at least 2 characters');
    }

    if (specialization.isEmpty) {
      throw ArgumentError('Specialization cannot be empty');
    }

    if (department.isEmpty) {
      throw ArgumentError('Department cannot be empty');
    }

    if (shift.isEmpty) {
      throw ArgumentError('Shift cannot be empty');
    }

    if (phoneNumber.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (yearsOfExperience < 0 || yearsOfExperience > 60) {
      throw ArgumentError('Years of experience must be between 0 and 60');
    }

    // Check if email already exists
    if (await _doctorRepository.emailExists(email)) {
      throw Exception('Email already exists');
    }

    // Create doctor
    final doctor = Doctor(
      id: _generateId(),
      name: name,
      specialization: specialization,
      department: department,
      shift: shift,
      phoneNumber: phoneNumber,
      email: email,
      gender: gender,
      yearsOfExperience: yearsOfExperience,
      createdAt: DateTime.now(),
    );

    // Additional validations
    if (!doctor.isValidEmail()) {
      throw ArgumentError('Invalid email format');
    }

    if (!doctor.isValidPhoneNumber()) {
      throw ArgumentError('Invalid phone number format');
    }

    if (!doctor.isValidDepartment()) {
      throw ArgumentError('Invalid department');
    }

    if (!doctor.isValidShift()) {
      throw ArgumentError('Invalid shift');
    }

    // Save to repository
    await _doctorRepository.save(doctor);

    return doctor;
  }

  // Get all doctors
  Future<List<Doctor>> getAllDoctors() {
    return _doctorRepository.getAll();
  }

  // Get doctor by ID
  Future<Doctor?> getDoctorById(String id) {
    return _doctorRepository.getById(id);
  }

  // Search doctors by specialization
  Future<List<Doctor>> searchBySpecialization(String specialization) {
    return _doctorRepository.getBySpecialization(specialization);
  }

  // Update doctor
  Future<void> updateDoctor(Doctor doctor) async {
    // Validate
    if (!doctor.isValidName()) {
      throw ArgumentError('Invalid name');
    }

    if (!doctor.isValidEmail()) {
      throw ArgumentError('Invalid email');
    }

    if (!doctor.isValidPhoneNumber()) {
      throw ArgumentError('Invalid phone number');
    }

    if (!doctor.isValidExperience()) {
      throw ArgumentError('Invalid years of experience');
    }

    return _doctorRepository.save(doctor);
  }

  // Delete doctor
  Future<bool> deleteDoctor(String id) async {
    final doctor = await _doctorRepository.getById(id);

    if (doctor == null) {
      throw Exception('Doctor not found');
    }

    return _doctorRepository.delete(id);
  }

  // Get doctor count
  Future<int> getDoctorCount() async {
    final doctors = await getAllDoctors();
    return doctors.length;
  }

  // Get doctors sorted by experience
  Future<List<Doctor>> getDoctorsSortedByExperience() async {
    final doctors = await getAllDoctors();
    doctors.sort((a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
    return doctors;
  }
}

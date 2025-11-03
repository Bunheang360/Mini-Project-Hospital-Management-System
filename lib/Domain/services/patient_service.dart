import '../models/patient.dart';
import '../enums/gender.dart';
import '../../Data/Repositories/patient_repository.dart';

class PatientService {
  final PatientRepository _patientRepository;

  PatientService(this._patientRepository);

  // Generate unique ID
  String _generateId() {
    return 'pat_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Create new patient
  Future<Patient> createPatient({
    required String name,
    required int age,
    required Gender gender,
    required String phoneNumber,
    required String address,
    String? medicalHistory,
  }) async {
    // Validate inputs
    if (name.isEmpty || name.length < 2) {
      throw ArgumentError('Name must be at least 2 characters');
    }

    if (age <= 0 || age > 150) {
      throw ArgumentError('Age must be between 1 and 150');
    }

    if (phoneNumber.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    if (address.isEmpty || address.length < 5) {
      throw ArgumentError('Address must be at least 5 characters');
    }

    // Check if phone number already exists
    if (await _patientRepository.phoneNumberExists(phoneNumber)) {
      throw Exception('Phone number already registered');
    }

    // Create patient
    final patient = Patient(
      id: _generateId(),
      name: name,
      age: age,
      gender: gender,
      phoneNumber: phoneNumber,
      address: address,
      medicalHistory: medicalHistory,
      registrationDate: DateTime.now(),
    );

    // Additional validations
    if (!patient.isValidPhoneNumber()) {
      throw ArgumentError('Invalid phone number format');
    }

    // Save to repository
    await _patientRepository.save(patient);

    return patient;
  }

  // Get all patients
  Future<List<Patient>> getAllPatients() {
    return _patientRepository.getAll();
  }

  // Get patient by ID
  Future<Patient?> getPatientById(String id) {
    return _patientRepository.getById(id);
  }

  // Search patients by name
  Future<List<Patient>> searchPatientsByName(String name) async {
    if (name.isEmpty) {
      return getAllPatients();
    }
    return _patientRepository.searchByName(name);
  }

  // Get patient by phone number
  Future<Patient?> getPatientByPhoneNumber(String phoneNumber) {
    return _patientRepository.getByPhoneNumber(phoneNumber);
  }

  // Update patient
  Future<void> updatePatient(Patient patient) async {
    // Validate
    if (!patient.isValidName()) {
      throw ArgumentError('Invalid name');
    }

    if (!patient.isValidAge()) {
      throw ArgumentError('Invalid age');
    }

    if (!patient.isValidPhoneNumber()) {
      throw ArgumentError('Invalid phone number');
    }

    if (!patient.isValidAddress()) {
      throw ArgumentError('Invalid address');
    }

    return _patientRepository.save(patient);
  }

  // Delete patient
  Future<bool> deletePatient(String id) async {
    final patient = await _patientRepository.getById(id);

    if (patient == null) {
      throw Exception('Patient not found');
    }

    return _patientRepository.delete(id);
  }

  // Get patient count
  Future<int> getPatientCount() async {
    final patients = await getAllPatients();
    return patients.length;
  }

  // Get patients (under 18)
  Future<List<Patient>> getKidPatients() async {
    final patients = await getAllPatients();
    return patients.where((patient) => patient.isKid()).toList();
  }

  // Get elderly patients (65+)
  Future<List<Patient>> getElderlyPatients() async {
    final patients = await getAllPatients();
    return patients.where((patient) => patient.isElderly()).toList();
  }

  // Get patients sorted by registration date (newest first)
  Future<List<Patient>> getPatientsSortedByDate() async {
    final patients = await getAllPatients();
    patients.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    return patients;
  }
}

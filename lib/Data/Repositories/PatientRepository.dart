import '../../Domain/models/Patient.dart';
import '../Storage/JsonStorage.dart';
import '../JsonConverter/PatientConverter.dart';

class PatientRepository {
  final JsonStorage _storage;
  final String _fileName = 'patients.json';

  PatientRepository(this._storage);

  // Get all patients
  Future<List<Patient>> getAll() async {
    final jsonList = await _storage.readJsonFile(_fileName);
    return PatientConverter.fromJsonList(jsonList);
  }

  // Get patient by ID
  Future<Patient?> getById(String id) async {
    final patients = await getAll();
    try {
      return patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get patient by phone number
  Future<Patient?> getByPhoneNumber(String phoneNumber) async {
    final patients = await getAll();
    try {
      return patients.firstWhere(
        (patient) => patient.phoneNumber == phoneNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Search patients by name
  Future<List<Patient>> searchByName(String name) async {
    final patients = await getAll();
    return patients
        .where(
          (patient) => patient.name.toLowerCase().contains(name.toLowerCase()),
        )
        .toList();
  }

  // Save (create or update) a patient
  Future<void> save(Patient patient) async {
    final patients = await getAll();

    // Check if patient already exists
    final existingIndex = patients.indexWhere((p) => p.id == patient.id);

    if (existingIndex != -1) {
      // Update existing patient
      patients[existingIndex] = patient;
    } else {
      // Add new patient
      patients.add(patient);
    }

    final jsonList = PatientConverter.toJsonList(patients);
    await _storage.writeJsonFile(_fileName, jsonList);
  }

  // Delete patient by ID
  Future<bool> delete(String id) async {
    final patients = await getAll();
    final initialLength = patients.length;

    patients.removeWhere((patient) => patient.id == id);

    if (patients.length < initialLength) {
      final jsonList = PatientConverter.toJsonList(patients);
      await _storage.writeJsonFile(_fileName, jsonList);
      return true;
    }

    return false;
  }

  // Check if phone number exists
  Future<bool> phoneNumberExists(String phoneNumber) async {
    final patient = await getByPhoneNumber(phoneNumber);
    return patient != null;
  }

  // Clear all patients
  Future<void> clear() async {
    await _storage.clearJsonFile(_fileName);
  }
}

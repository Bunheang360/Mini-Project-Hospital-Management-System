import '../../Domain/models/doctor.dart';
import '../Storage/json_storage.dart';
import '../JsonConverter/doctor_converter.dart';

class DoctorRepository {
  final JsonStorage _storage;
  final String _fileName = 'doctors.json';

  DoctorRepository(this._storage);

  // Get all doctors
  Future<List<Doctor>> getAll() async {
    final jsonList = await _storage.readJsonFile(_fileName);
    return DoctorConverter.fromJsonList(jsonList);
  }

  // Get doctor by ID
  Future<Doctor?> getById(String id) async {
    final doctors = await getAll();
    try {
      return doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get doctors by specialization
  Future<List<Doctor>> getBySpecialization(String specialization) async {
    final doctors = await getAll();
    return doctors
        .where(
          (doctor) => doctor.specialization.toLowerCase().contains(
            specialization.toLowerCase(),
          ),
        )
        .toList();
  }

  // Save (create or update) a doctor
  Future<void> save(Doctor doctor) async {
    final doctors = await getAll();

    // Check if doctor already exists
    final existingIndex = doctors.indexWhere((d) => d.id == doctor.id);

    if (existingIndex != -1) {
      // Update existing doctor
      doctors[existingIndex] = doctor;
    } else {
      // Add new doctor
      doctors.add(doctor);
    }

    final jsonList = DoctorConverter.toJsonList(doctors);
    await _storage.writeJsonFile(_fileName, jsonList);
  }

  // Delete doctor by ID
  Future<bool> delete(String id) async {
    final doctors = await getAll();
    final initialLength = doctors.length;

    doctors.removeWhere((doctor) => doctor.id == id);

    if (doctors.length < initialLength) {
      final jsonList = DoctorConverter.toJsonList(doctors);
      await _storage.writeJsonFile(_fileName, jsonList);
      return true;
    }

    return false;
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final doctors = await getAll();
    return doctors.any((doctor) => doctor.email == email);
  }

  // Clear all doctors
  Future<void> clear() async {
    await _storage.clearJsonFile(_fileName);
  }
}

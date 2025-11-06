import '../../Domain/models/patient.dart';
import '../Storage/json_storage.dart';

class PatientRepository {
  final JsonStorage _storage = JsonStorage('patients.json');

  void addPatient(Patient patient) {
    final patients = _storage.read();
    patients.add(patient.toJson());
    _storage.write(patients);
  }

  List<Patient> getAllPatients() {
    final patients = _storage.read();
    return patients.map((json) => Patient.fromJson(json)).toList();
  }

  Patient? getPatientById(String id) {
    final patients = getAllPatients();
    try {
      return patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void updatePatient(Patient patient) {
    final patients = _storage.read();
    final index = patients.indexWhere((p) => p['id'] == patient.id);
    if (index != -1) {
      patients[index] = patient.toJson();
      _storage.write(patients);
    }
  }

  void deletePatient(String id) {
    final patients = _storage.read();
    patients.removeWhere((p) => p['id'] == id);
    _storage.write(patients);
  }
}

import '../Domain/models/patient.dart';
import '../Domain/enums/gender.dart';
import '../Data/Repositories/patient_repository.dart';
import 'validation_service.dart';

class PatientService {
  final PatientRepository _repository;

  PatientService(this._repository);

  bool addPatient({
    required String id,
    required String name,
    required Gender gender,
    required int age,
    required String phoneNumber,
    required String address,
    String? medicalHistory,
  }) {
    if (!ValidationService.isValidPhone(phoneNumber)) {
      return false;
    }

    if (_repository.getPatientById(id) != null) {
      return false;
    }

    final patient = Patient(
      id: id,
      name: name,
      gender: gender,
      age: age,
      phoneNumber: phoneNumber,
      address: address,
      medicalHistory: medicalHistory,
      registrationDate: DateTime.now(),
    );

    _repository.addPatient(patient);
    return true;
  }

  List<Patient> getAllPatients() {
    return _repository.getAllPatients();
  }

  Patient? getPatientById(String id) {
    return _repository.getPatientById(id);
  }

  List<Patient> searchPatientsByName(String name) {
    final patients = _repository.getAllPatients();
    return patients
        .where((p) => p.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  List<Patient> getPatientsByAgeRange(int minAge, int maxAge) {
    final patients = _repository.getAllPatients();
    return patients.where((p) => p.age >= minAge && p.age <= maxAge).toList();
  }

  bool updatePatient(Patient patient) {
    if (_repository.getPatientById(patient.id) == null) {
      return false;
    }
    _repository.updatePatient(patient);
    return true;
  }

  bool deletePatient(String id) {
    if (_repository.getPatientById(id) == null) {
      return false;
    }
    _repository.deletePatient(id);
    return true;
  }

  int getTotalPatients() {
    return _repository.getAllPatients().length;
  }
}

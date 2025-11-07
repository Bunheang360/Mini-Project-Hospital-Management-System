import '../Domain/models/doctor.dart';
import '../Domain/models/receptionist.dart';
import '../Domain/enums/gender.dart';
import '../Domain/enums/shift.dart';
import '../Data/Repositories/user_repository.dart';

class UserService {
  final UserRepository _repository;

  UserService(this._repository);

  // Doctor operations
  bool addDoctor({
    required String id,
    required String username,
    required String password,
    required String name,
    required Gender gender,
    required String phone,
    required String email,
    required String specialization,
    required String department,
    Shift shift = Shift.morning,
  }) {
    if (_repository.isUsernameExists(username)) {
      return false;
    }

    final doctor = Doctor(
      id: id,
      username: username,
      password: password,
      name: name,
      gender: gender,
      phone: phone,
      email: email,
      specialization: specialization,
      department: department,
      shift: shift,
    );

    if (!doctor.validate()) {
      return false;
    }

    _repository.addDoctor(doctor);
    return true;
  }

  List<Doctor> getAllDoctors() {
    return _repository.getAllDoctors();
  }

  Doctor? getDoctorById(String id) {
    return _repository.getDoctorById(id);
  }

  List<Doctor> searchDoctorsBySpecialization(String specialization) {
    final doctors = _repository.getAllDoctors();
    return doctors
        .where(
          (d) => d.specialization.toLowerCase().contains(
            specialization.toLowerCase(),
          ),
        )
        .toList();
  }

  List<Doctor> filterDoctorsByDepartment(String department) {
    final doctors = _repository.getAllDoctors();
    return doctors
        .where(
          (d) => d.department.toLowerCase().contains(department.toLowerCase()),
        )
        .toList();
  }

  List<Doctor> getDoctorsByShift(Shift shift) {
    final doctors = _repository.getAllDoctors();
    return doctors.where((d) => d.shift == shift).toList();
  }

  bool updateDoctor(Doctor doctor) {
    if (_repository.getDoctorById(doctor.id) == null) {
      return false;
    }

    if (!doctor.validate()) {
      return false;
    }

    _repository.updateDoctor(doctor);
    return true;
  }

  bool deleteDoctor(String id) {
    if (_repository.getDoctorById(id) == null) {
      return false;
    }
    _repository.deleteDoctor(id);
    return true;
  }

  // Receptionist operations
  bool addReceptionist({
    required String id,
    required String username,
    required String password,
    required String name,
    required Gender gender,
    required String phone,
    required String email,
    required Shift shift,
  }) {
    if (_repository.isUsernameExists(username)) {
      return false;
    }

    final receptionist = Receptionist(
      id: id,
      username: username,
      password: password,
      name: name,
      gender: gender,
      phone: phone,
      email: email,
      shift: shift,
    );

    if (!receptionist.validate()) {
      return false;
    }

    _repository.addReceptionist(receptionist);
    return true;
  }

  List<Receptionist> getAllReceptionists() {
    return _repository.getAllReceptionists();
  }

  Receptionist? getReceptionistById(String id) {
    return _repository.getReceptionistById(id);
  }

  List<Receptionist> getReceptionistsByShift(Shift shift) {
    final receptionists = _repository.getAllReceptionists();
    return receptionists.where((r) => r.shift == shift).toList();
  }

  bool updateReceptionist(Receptionist receptionist) {
    if (_repository.getReceptionistById(receptionist.id) == null) {
      return false;
    }

    if (!receptionist.validate()) {
      return false;
    }

    _repository.updateReceptionist(receptionist);
    return true;
  }

  bool deleteReceptionist(String id) {
    if (_repository.getReceptionistById(id) == null) {
      return false;
    }
    _repository.deleteReceptionist(id);
    return true;
  }
}
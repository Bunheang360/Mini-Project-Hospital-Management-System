import '../../Domain/models/user.dart';
import '../../Domain/models/admin.dart';
import '../../Domain/models/doctor.dart';
import '../../Domain/models/receptionist.dart';
import '../../Domain/enums/gender.dart';
import '../Storage/json_storage.dart';

class UserRepository {
  final JsonStorage _adminStorage = JsonStorage('admins.json');
  final JsonStorage _doctorStorage = JsonStorage('doctors.json');
  final JsonStorage _receptionistStorage = JsonStorage('receptionists.json');

  UserRepository() {
    _initializeDefaultAdmin();
  }

  void _initializeDefaultAdmin() {
    final admins = _adminStorage.read();
    if (admins.isEmpty) {
      final defaultAdmin = Admin(
        id: 'ADM001',
        username: 'Admin',
        password: 'Admin123',
        name: 'System Administrator',
        gender: Gender.male,
        phone: '1234567890',
        email: 'admin@hospital.com',
      );
      _adminStorage.write([defaultAdmin.toJson()]);
    }
  }

  User? authenticate(String username, String password) {
    final admins = _adminStorage.read();
    for (var json in admins) {
      final admin = Admin.fromJson(json);
      if (admin.username == username && admin.password == password) {
        return admin;
      }
    }

    final doctors = _doctorStorage.read();
    for (var json in doctors) {
      final doctor = Doctor.fromJson(json);
      if (doctor.username == username && doctor.password == password) {
        return doctor;
      }
    }

    final receptionists = _receptionistStorage.read();
    for (var json in receptionists) {
      final receptionist = Receptionist.fromJson(json);
      if (receptionist.username == username &&
          receptionist.password == password) {
        return receptionist;
      }
    }

    return null;
  }

  // Doctor operations
  void addDoctor(Doctor doctor) {
    final doctors = _doctorStorage.read();
    doctors.add(doctor.toJson());
    _doctorStorage.write(doctors);
  }

  List<Doctor> getAllDoctors() {
    final doctors = _doctorStorage.read();
    return doctors.map((json) => Doctor.fromJson(json)).toList();
  }

  Doctor? getDoctorById(String id) {
    final doctors = getAllDoctors();
    try {
      return doctors.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateDoctor(Doctor doctor) {
    final doctors = _doctorStorage.read();
    final index = doctors.indexWhere((d) => d['id'] == doctor.id);
    if (index != -1) {
      doctors[index] = doctor.toJson();
      _doctorStorage.write(doctors);
    }
  }

  void deleteDoctor(String id) {
    final doctors = _doctorStorage.read();
    doctors.removeWhere((d) => d['id'] == id);
    _doctorStorage.write(doctors);
  }

  // Receptionist operations
  void addReceptionist(Receptionist receptionist) {
    final receptionists = _receptionistStorage.read();
    receptionists.add(receptionist.toJson());
    _receptionistStorage.write(receptionists);
  }

  List<Receptionist> getAllReceptionists() {
    final receptionists = _receptionistStorage.read();
    return receptionists.map((json) => Receptionist.fromJson(json)).toList();
  }

  Receptionist? getReceptionistById(String id) {
    final receptionists = getAllReceptionists();
    try {
      return receptionists.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateReceptionist(Receptionist receptionist) {
    final receptionists = _receptionistStorage.read();
    final index = receptionists.indexWhere((r) => r['id'] == receptionist.id);
    if (index != -1) {
      receptionists[index] = receptionist.toJson();
      _receptionistStorage.write(receptionists);
    }
  }

  void deleteReceptionist(String id) {
    final receptionists = _receptionistStorage.read();
    receptionists.removeWhere((r) => r['id'] == id);
    _receptionistStorage.write(receptionists);
  }

  bool isUsernameExists(String username) {
    final admins = _adminStorage.read();
    if (admins.any((a) => a['username'] == username)) return true;

    final doctors = _doctorStorage.read();
    if (doctors.any((d) => d['username'] == username)) return true;

    final receptionists = _receptionistStorage.read();
    if (receptionists.any((r) => r['username'] == username)) return true;

    return false;
  }
}

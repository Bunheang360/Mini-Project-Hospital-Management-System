import '../../Domain/models/Appointment.dart';
import '../../Domain/enums/AppointmentStatus.dart';
import '../Storage/JsonStorage.dart';
import '../JsonConverter/AppointmentConverter.dart';

class AppointmentRepository {
  final JsonStorage _storage;
  final String _fileName = 'appointments.json';

  AppointmentRepository(this._storage);

  // Get all appointments
  Future<List<Appointment>> getAll() async {
    final jsonList = await _storage.readJsonFile(_fileName);
    return AppointmentConverter.fromJsonList(jsonList);
  }

  // Get appointment by ID
  Future<Appointment?> getById(String id) async {
    final appointments = await getAll();
    try {
      return appointments.firstWhere((appointment) => appointment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get appointments by patient ID
  Future<List<Appointment>> getByPatientId(String patientId) async {
    final appointments = await getAll();
    return appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
  }

  // Get appointments by doctor ID
  Future<List<Appointment>> getByDoctorId(String doctorId) async {
    final appointments = await getAll();
    return appointments
        .where((appointment) => appointment.doctorId == doctorId)
        .toList();
  }

  // Get appointments by status
  Future<List<Appointment>> getByStatus(AppointmentStatus status) async {
    final appointments = await getAll();
    return appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }

  // Get appointments by date
  Future<List<Appointment>> getByDate(DateTime date) async {
    final appointments = await getAll();
    return appointments.where((appointment) {
      final appointmentDate = appointment.appointmentDate;
      return appointmentDate.year == date.year &&
          appointmentDate.month == date.month &&
          appointmentDate.day == date.day;
    }).toList();
  }

  // Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments() async {
    final appointments = await getAll();
    final now = DateTime.now();
    return appointments
        .where(
          (appointment) =>
              appointment.appointmentDate.isAfter(now) &&
              appointment.status == AppointmentStatus.scheduled,
        )
        .toList();
  }

  // Save (create or update) an appointment
  Future<void> save(Appointment appointment) async {
    final appointments = await getAll();

    // Check if appointment already exists
    final existingIndex = appointments.indexWhere(
      (a) => a.id == appointment.id,
    );

    if (existingIndex != -1) {
      // Update existing appointment
      appointments[existingIndex] = appointment;
    } else {
      // Add new appointment
      appointments.add(appointment);
    }

    final jsonList = AppointmentConverter.toJsonList(appointments);
    await _storage.writeJsonFile(_fileName, jsonList);
  }

  // Delete appointment by ID
  Future<bool> delete(String id) async {
    final appointments = await getAll();
    final initialLength = appointments.length;

    appointments.removeWhere((appointment) => appointment.id == id);

    if (appointments.length < initialLength) {
      final jsonList = AppointmentConverter.toJsonList(appointments);
      await _storage.writeJsonFile(_fileName, jsonList);
      return true;
    }

    return false;
  }

  // Clear all appointments
  Future<void> clear() async {
    await _storage.clearJsonFile(_fileName);
  }
}

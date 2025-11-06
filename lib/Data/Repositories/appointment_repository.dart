import '../../Domain/models/appointment.dart';
import '../../Domain/enums/appointment_status.dart';
import '../Storage/json_storage.dart';

class AppointmentRepository {
  final JsonStorage _storage = JsonStorage('appointments.json');

  void addAppointment(Appointment appointment) {
    final appointments = _storage.read();
    appointments.add(appointment.toJson());
    _storage.write(appointments);
  }

  List<Appointment> getAllAppointments() {
    final appointments = _storage.read();
    return appointments.map((json) => Appointment.fromJson(json)).toList();
  }

  Appointment? getAppointmentById(String id) {
    final appointments = getAllAppointments();
    try {
      return appointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Appointment> getAppointmentsByDoctorId(String doctorId) {
    final appointments = getAllAppointments();
    return appointments.where((a) => a.doctorId == doctorId).toList();
  }

  List<Appointment> getAppointmentsByPatientId(String patientId) {
    final appointments = getAllAppointments();
    return appointments.where((a) => a.patientId == patientId).toList();
  }

  List<Appointment> getUpcomingAppointmentsByDoctorId(String doctorId) {
    final appointments = getAppointmentsByDoctorId(doctorId);
    final now = DateTime.now();
    return appointments
        .where(
          (a) =>
              a.dateTime.isAfter(now) &&
              a.status == AppointmentStatus.scheduled,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void updateAppointment(Appointment appointment) {
    final appointments = _storage.read();
    final index = appointments.indexWhere((a) => a['id'] == appointment.id);
    if (index != -1) {
      appointments[index] = appointment.toJson();
      _storage.write(appointments);
    }
  }

  void deleteAppointment(String id) {
    final appointments = _storage.read();
    appointments.removeWhere((a) => a['id'] == id);
    _storage.write(appointments);
  }
}

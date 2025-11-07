import '../Domain/models/appointment.dart';
import '../Domain/enums/appointment_status.dart';
import '../Data/Repositories/appointment_repository.dart';
import '../Data/Repositories/patient_repository.dart';
import '../Data/Repositories/user_repository.dart';

class AppointmentService {
  final AppointmentRepository _repository;
  final PatientRepository _patientRepository;
  final UserRepository _userRepository;

  AppointmentService(
    this._repository,
    this._patientRepository,
    this._userRepository,
  );

  bool createAppointment({
    required String id,
    required String patientId,
    required String doctorId,
    String? roomId,
    required DateTime dateTime,
    required String reason,
    String? notes,
  }) {
    // Validate patient exists
    if (_patientRepository.getPatientById(patientId) == null) {
      return false;
    }

    // Validate doctor exists
    if (_userRepository.getDoctorById(doctorId) == null) {
      return false;
    }

    // Check if appointment already exists
    if (_repository.getAppointmentById(id) != null) {
      return false;
    }

    // Check if appointment is in the past
    if (dateTime.isBefore(DateTime.now())) {
      return false;
    }

    final appointment = Appointment(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      roomId: roomId,
      dateTime: dateTime,
      reason: reason,
      notes: notes,
    );

    if (!appointment.validate()) {
      return false;
    }

    _repository.addAppointment(appointment);
    return true;
  }

  List<Appointment> getAllAppointments() {
    return _repository.getAllAppointments();
  }

  Appointment? getAppointmentById(String id) {
    return _repository.getAppointmentById(id);
  }

  List<Appointment> getAppointmentsByDoctorId(String doctorId) {
    final appointments = _repository.getAllAppointments();
    return appointments.where((a) => a.doctorId == doctorId).toList();
  }

  List<Appointment> getAppointmentsByPatientId(String patientId) {
    final appointments = _repository.getAllAppointments();
    return appointments.where((a) => a.patientId == patientId).toList();
  }

  List<Appointment> getAppointmentsByRoomId(String roomId) {
    final appointments = _repository.getAllAppointments();
    return appointments.where((a) => a.roomId == roomId).toList();
  }

  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    final appointments = _repository.getAllAppointments();
    return appointments.where((a) => a.status == status).toList();
  }

  List<Appointment> getUpcomingAppointments(String doctorId) {
    final appointments = _repository.getAllAppointments();
    final now = DateTime.now();
    return appointments
        .where((a) =>
            a.doctorId == doctorId &&
            a.dateTime.isAfter(now) &&
            a.isScheduled()).toList();
  }

  List<Appointment> getTodayAppointments(String doctorId) {
    final appointments = _repository.getAllAppointments();
    return appointments
        .where((a) => a.doctorId == doctorId && a.isToday() && a.isScheduled())
        .toList();
  }

  bool updateAppointmentStatus(
    String id,
    AppointmentStatus status,
    String? notes,
  ) {
    final appointment = _repository.getAppointmentById(id);
    if (appointment == null) {
      return false;
    }

    appointment.status = status;
    if (notes != null) {
      appointment.notes = notes;
    }

    _repository.updateAppointment(appointment);
    return true;
  }

  bool rescheduleAppointment(String id, DateTime newDateTime) {
    final appointment = _repository.getAppointmentById(id);
    if (appointment == null) {
      return false;
    }

    if (newDateTime.isBefore(DateTime.now())) {
      return false;
    }

    final updated = Appointment(
      id: appointment.id,
      patientId: appointment.patientId,
      doctorId: appointment.doctorId,
      roomId: appointment.roomId,
      dateTime: newDateTime,
      status: appointment.status,
      reason: appointment.reason,
      notes: appointment.notes,
    );

    _repository.updateAppointment(updated);
    return true;
  }

  bool deleteAppointment(String id) {
    if (_repository.getAppointmentById(id) == null) {
      return false;
    }
    _repository.deleteAppointment(id);
    return true;
  }

  Map<AppointmentStatus, int> getAppointmentStatistics() {
    final appointments = _repository.getAllAppointments();
    return {
      AppointmentStatus.scheduled:
          appointments.where((a) => a.isScheduled()).length,
      AppointmentStatus.completed:
          appointments.where((a) => a.isCompleted()).length,
      AppointmentStatus.cancelled:
          appointments.where((a) => a.isCancelled()).length,
    };
  }
}

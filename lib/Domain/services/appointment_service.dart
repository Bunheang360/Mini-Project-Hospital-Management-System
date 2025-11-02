import '../models/appointment.dart';
import '../enums/appointment_status.dart';
import '../../Data/Repositories/appointment_repository.dart';
import '../../Data/Repositories/patient_repository.dart';
import '../../Data/Repositories/doctor_repository.dart';
import '../../Data/Repositories/room_repository.dart';

class AppointmentService {
  final AppointmentRepository _appointmentRepository;
  final PatientRepository _patientRepository;
  final DoctorRepository _doctorRepository;
  final RoomRepository _roomRepository;

  AppointmentService(
    this._appointmentRepository,
    this._patientRepository,
    this._doctorRepository,
    this._roomRepository,
  );

  // Generate unique ID
  String _generateId() {
    return 'apt_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Create new appointment
  Future<Appointment> createAppointment({
    required String patientId,
    required String doctorId,
    required String roomId,
    required DateTime appointmentDate,
    required String reason,
  }) async {
    // Validate inputs
    if (reason.isEmpty || reason.length < 5) {
      throw ArgumentError('Reason must be at least 5 characters');
    }

    // Verify patient exists
    final patient = await _patientRepository.getById(patientId);
    if (patient == null) {
      throw Exception('Patient not found');
    }

    // Verify doctor exists
    final doctor = await _doctorRepository.getById(doctorId);
    if (doctor == null) {
      throw Exception('Doctor not found');
    }

    // Verify room exists
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Create appointment
    final appointment = Appointment(
      id: _generateId(),
      patientId: patientId,
      doctorId: doctorId,
      roomId: roomId,
      appointmentDate: appointmentDate,
      status: AppointmentStatus.scheduled,
      reason: reason,
      createdAt: DateTime.now(),
    );

    // Validate appointment date
    if (!appointment.isValidAppointmentDate()) {
      throw ArgumentError('Appointment date cannot be in the past');
    }

    // Check for conflicting appointments with doctor
    final doctorConflicts = await checkDoctorAvailability(doctorId, appointmentDate);
    if (doctorConflicts.isNotEmpty) {
      throw Exception('Doctor already has an appointment at this time');
    }

    // Check for conflicting appointments with room
    final roomConflicts = await checkRoomAvailability(roomId, appointmentDate);
    if (roomConflicts.isNotEmpty) {
      throw Exception('Room is already booked at this time');
    }

    // Save to repository
    await _appointmentRepository.save(appointment);

    return appointment;
  }

  // Get all appointments
  Future<List<Appointment>> getAllAppointments() async {
    return await _appointmentRepository.getAll();
  }

  // Get appointment by ID
  Future<Appointment?> getAppointmentById(String id) async {
    return await _appointmentRepository.getById(id);
  }

  // Get appointments by patient ID
  Future<List<Appointment>> getAppointmentsByPatient(String patientId) async {
    return await _appointmentRepository.getByPatientId(patientId);
  }

  // Get appointments by doctor ID
  Future<List<Appointment>> getAppointmentsByDoctor(String doctorId) async {
    return await _appointmentRepository.getByDoctorId(doctorId);
  }

  // Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments() async {
    return await _appointmentRepository.getUpcomingAppointments();
  }

  // Get today's appointments
  Future<List<Appointment>> getTodaysAppointments() async {
    final appointments = await getAllAppointments();
    return appointments.where((apt) => apt.isToday()).toList();
  }

  // Check doctor availability at specific date/time
  Future<List<Appointment>> checkDoctorAvailability(
    String doctorId,
    DateTime dateTime, {
    String? excludeAppointmentId,
  }) async {
    final doctorAppointments = await getAppointmentsByDoctor(doctorId);

    // Check for appointments within 1 hour window
    return doctorAppointments.where((apt) {
      if (apt.status != AppointmentStatus.scheduled) return false;
      if (excludeAppointmentId != null && apt.id == excludeAppointmentId) {
        return false; // Exclude current appointment
      }

      final diff = apt.appointmentDate.difference(dateTime).abs();
      return diff.inMinutes < 60; // Within 1 hour
    }).toList();
  }

  // Check room availability at specific date/time
  Future<List<Appointment>> checkRoomAvailability(
    String roomId,
    DateTime dateTime, {
    String? excludeAppointmentId,
  }) async {
    final allAppointments = await getAllAppointments();

    // Check for scheduled appointments using this room within 1 hour window
    return allAppointments.where((apt) {
      if (apt.status != AppointmentStatus.scheduled) return false;
      if (apt.roomId != roomId) return false;
      if (excludeAppointmentId != null && apt.id == excludeAppointmentId) {
        return false; // Exclude current appointment
      }

      final diff = apt.appointmentDate.difference(dateTime).abs();
      return diff.inMinutes < 60; // Within 1 hour
    }).toList();
  }

  // Update appointment
  Future<void> updateAppointment(Appointment appointment) async {
    // Validate
    if (!appointment.isValidReason()) {
      throw ArgumentError('Invalid reason');
    }

    if (!appointment.isValidAppointmentDate()) {
      throw ArgumentError('Invalid appointment date');
    }

    // Check for conflicts if appointment is scheduled
    if (appointment.status == AppointmentStatus.scheduled) {
      // Check doctor availability (exclude current appointment)
      final doctorConflicts = await checkDoctorAvailability(
        appointment.doctorId,
        appointment.appointmentDate,
        excludeAppointmentId: appointment.id,
      );

      if (doctorConflicts.isNotEmpty) {
        throw Exception('Doctor already has an appointment at this time');
      }

      // Check room availability (exclude current appointment)
      final roomConflicts = await checkRoomAvailability(
        appointment.roomId,
        appointment.appointmentDate,
        excludeAppointmentId: appointment.id,
      );

      if (roomConflicts.isNotEmpty) {
        throw Exception('Room is already booked at this time');
      }
    }

    await _appointmentRepository.save(appointment);
  }

  // Cancel appointment
  Future<void> cancelAppointment(String id) async {
    final appointment = await _appointmentRepository.getById(id);

    if (appointment == null) {
      throw Exception('Appointment not found');
    }

    if (!appointment.canBeCancelled()) {
      throw Exception('Only scheduled appointments can be cancelled');
    }

    appointment.cancel();
    await _appointmentRepository.save(appointment);
  }

  // Complete appointment
  Future<void> completeAppointment(String id, {String? notes}) async {
    final appointment = await _appointmentRepository.getById(id);

    if (appointment == null) {
      throw Exception('Appointment not found');
    }

    if (!appointment.canBeCompleted()) {
      throw Exception('Only scheduled appointments can be completed');
    }

    appointment.complete(notes);
    await _appointmentRepository.save(appointment);
  }

  // Reschedule appointment
  Future<void> rescheduleAppointment(String id, DateTime newDate) async {
    final appointment = await _appointmentRepository.getById(id);

    if (appointment == null) {
      throw Exception('Appointment not found');
    }

    if (appointment.status != AppointmentStatus.scheduled) {
      throw Exception('Only scheduled appointments can be rescheduled');
    }

    // Check doctor availability at new time (exclude current appointment)
    final doctorConflicts = await checkDoctorAvailability(
      appointment.doctorId,
      newDate,
      excludeAppointmentId: appointment.id,
    );

    if (doctorConflicts.isNotEmpty) {
      throw Exception('Doctor already has an appointment at this time');
    }

    // Check room availability at new time (exclude current appointment)
    final roomConflicts = await checkRoomAvailability(
      appointment.roomId,
      newDate,
      excludeAppointmentId: appointment.id,
    );

    if (roomConflicts.isNotEmpty) {
      throw Exception('Room is already booked at this time');
    }

    // Create new appointment with new date
    final rescheduled = Appointment(
      id: appointment.id,
      patientId: appointment.patientId,
      doctorId: appointment.doctorId,
      roomId: appointment.roomId,
      appointmentDate: newDate,
      status: AppointmentStatus.scheduled,
      reason: appointment.reason,
      notes: appointment.notes,
      createdAt: appointment.createdAt,
    );

    await _appointmentRepository.save(rescheduled);
  }

  // Delete appointment
  Future<bool> deleteAppointment(String id) async {
    final appointment = await _appointmentRepository.getById(id);

    if (appointment == null) {
      throw Exception('Appointment not found');
    }

    return await _appointmentRepository.delete(id);
  }

  // Get appointment count
  Future<int> getAppointmentCount() async {
    final appointments = await getAllAppointments();
    return appointments.length;
  }

  // Get scheduled appointment count
  Future<int> getScheduledAppointmentCount() async {
    final appointments = await _appointmentRepository.getByStatus(
      AppointmentStatus.scheduled,
    );
    return appointments.length;
  }
}

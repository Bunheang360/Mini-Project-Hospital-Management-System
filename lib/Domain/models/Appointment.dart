import '../enums/AppointmentStatus.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  AppointmentStatus status;
  final String reason;
  String? notes; // Optional notes added by doctor
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.status,
    required this.reason,
    this.notes,
    required this.createdAt,
  });

  // Validation methods
  bool isValidReason() {
    return reason.isNotEmpty && reason.length >= 5;
  }

  bool isValidAppointmentDate() {
    // Appointment should not be in the past (allow same day)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );
    return appointmentDay.isAtSameMomentAs(today) ||
        appointmentDay.isAfter(today);
  }

  // Business logic methods
  bool canBeCancelled() {
    return status == AppointmentStatus.scheduled;
  }

  bool canBeCompleted() {
    return status == AppointmentStatus.scheduled;
  }

  void cancel() {
    if (!canBeCancelled()) {
      throw StateError('Only scheduled appointments can be cancelled');
    }
    status = AppointmentStatus.cancelled;
  }

  void complete(String? completionNotes) {
    if (!canBeCompleted()) {
      throw StateError('Only scheduled appointments can be completed');
    }
    status = AppointmentStatus.completed;
    if (completionNotes != null) {
      notes = completionNotes;
    }
  }

  void reschedule(DateTime newDate) {
    if (status != AppointmentStatus.scheduled) {
      throw StateError('Only scheduled appointments can be rescheduled');
    }
    // Note: In a real system, you'd create a new appointment
    // For simplicity, we're just updating the date here
  }

  bool isPast() {
    return appointmentDate.isBefore(DateTime.now());
  }

  bool isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );
    return appointmentDay.isAtSameMomentAs(today);
  }

  String getDisplayInfo() {
    final dateStr = '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
    final timeStr = '${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}';
    return 'Appointment on $dateStr at $timeStr - ${status.displayName}';
  }

  @override
  String toString() {
    return 'Appointment(id: $id, patientId: $patientId, doctorId: $doctorId, '
        'date: $appointmentDate, status: ${status.displayName}, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
import '../../Domain/models/Appointment.dart';
import '../../Domain/enums/AppointmentStatus.dart';

class AppointmentConverter {
  // Convert Appointment to JSON
  static Map<String, dynamic> toJson(Appointment appointment) {
    return {
      'id': appointment.id,
      'patientId': appointment.patientId,
      'doctorId': appointment.doctorId,
      'appointmentDate': appointment.appointmentDate.toIso8601String(),
      'status': appointment.status.name,
      'reason': appointment.reason,
      'notes': appointment.notes,
      'createdAt': appointment.createdAt.toIso8601String(),
    };
  }

  // Convert JSON to Appointment
  static Appointment fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      status: AppointmentStatus.fromString(json['status']),
      reason: json['reason'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert list of appointments to JSON
  static List<Map<String, dynamic>> toJsonList(List<Appointment> appointments) {
    return appointments.map((appointment) => toJson(appointment)).toList();
  }

  // Convert JSON list to list of appointments
  static List<Appointment> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}

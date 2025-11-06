import '../enums/appointment_status.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String? roomId;
  final DateTime dateTime;
  AppointmentStatus status;
  final String reason;
  String? notes;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.roomId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    required this.reason,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      roomId: json['roomId'],
      dateTime: DateTime.parse(json['dateTime']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      reason: json['reason'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'roomId': roomId,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'reason': reason,
      'notes': notes,
    };
  }

  void displayInfo() {
    print('Appointment ID: $id');
    print('Patient ID: $patientId');
    print('Doctor ID: $doctorId');
    if (roomId != null) {
      print('Room ID: $roomId');
    }
    print('Date & Time: ${dateTime.toString()}');
    print('Status: ${status.name}');
    print('Reason: $reason');
    if (notes != null) {
      print('Notes: $notes');
    }
  }
}

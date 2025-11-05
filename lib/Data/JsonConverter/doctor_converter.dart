import '../../Domain/models/doctor.dart';
import '../../Domain/enums/gender.dart';
import '../../Domain/enums/shift.dart';

class DoctorConverter {
  // Convert Doctor to JSON
  static Map<String, dynamic> toJson(Doctor doctor) {
    return {
      'id': doctor.id,
      'name': doctor.name,
      'specialization': doctor.specialization,
      'department': doctor.department,
      'shift': doctor.shift.name,
      'phoneNumber': doctor.phoneNumber,
      'email': doctor.email,
      'gender': doctor.gender.name,
      'yearsOfExperience': doctor.yearsOfExperience,
      'createdAt': doctor.createdAt.toIso8601String(),
    };
  }

  // Convert JSON to Doctor
  static Doctor fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      department: json['department'] ?? 'General', // Default for old data
      shift: json['shift'] != null
          ? Shift.fromString(json['shift'])
          : Shift.morning, // Default for old data
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      gender: Gender.fromString(json['gender']),
      yearsOfExperience: json['yearsOfExperience'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert list of doctors to JSON
  static List<Map<String, dynamic>> toJsonList(List<Doctor> doctors) {
    return doctors.map((doctor) => toJson(doctor)).toList();
  }

  // Convert JSON list to list of doctors
  static List<Doctor> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}

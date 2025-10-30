import '../../Domain/models/Patient.dart';
import '../../Domain/enums/Gender.dart';

class PatientConverter {
  // Convert Patient to JSON
  static Map<String, dynamic> toJson(Patient patient) {
    return {
      'id': patient.id,
      'name': patient.name,
      'age': patient.age,
      'gender': patient.gender.name,
      'phoneNumber': patient.phoneNumber,
      'address': patient.address,
      'medicalHistory': patient.medicalHistory,
      'registrationDate': patient.registrationDate.toIso8601String(),
    };
  }

  // Convert JSON to Patient
  static Patient fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: Gender.fromString(json['gender']),
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      medicalHistory: json['medicalHistory'],
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }

  // Convert list of patients to JSON
  static List<Map<String, dynamic>> toJsonList(List<Patient> patients) {
    return patients.map((patient) => toJson(patient)).toList();
  }

  // Convert JSON list to list of patients
  static List<Patient> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}

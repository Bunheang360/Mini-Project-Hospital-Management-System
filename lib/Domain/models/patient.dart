import '../enums/gender.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final String phoneNumber;
  final String address;
  final String? medicalHistory;
  final DateTime registrationDate;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    this.medicalHistory,
    required this.registrationDate,
  });

  // Validation methods
  bool isValidName() {
    return name.isNotEmpty && name.length >= 2;
  }

  bool isValidAge() {
    return age > 0 && age <= 150;
  }

  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^\d{8,15}$');
    return phoneRegex.hasMatch(
      phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''),
    );
  }

  bool isValidAddress() {
    return address.isNotEmpty && address.length >= 5;
  }

  String getDisplayInfo() {
    return '$name (${gender.name}, $age years) - $phoneNumber';
  }

  // JSON serialization
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      medicalHistory: json['medicalHistory'],
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender.name,
      'phoneNumber': phoneNumber,
      'address': address,
      'medicalHistory': medicalHistory,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  // Display method for console output
  void displayInfo() {
    print('Patient ID: $id');
    print('Name: $name');
    print('Age: $age');
    print('Gender: ${gender.name}');
    print('Phone: $phoneNumber');
    print('Address: $address');
    if (medicalHistory != null) {
      print('Medical History: $medicalHistory');
    }
    print('Registration Date: ${registrationDate.toString().split(' ')[0]}');
  }

  // Helper method to check if patient is a kid
  bool isKid() {
    return age < 18;
  }

  // Helper method to check if patient is elderly
  bool isElderly() {
    return age >= 65;
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $name, age: $age, '
        'gender: ${gender.name}, phone: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

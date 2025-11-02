import '../../Domain/models/user.dart';
import '../../Domain/models/admin.dart';
import '../../Domain/models/receptionist.dart';
import '../../Domain/models/doctor_user.dart';
import '../../Domain/enums/user_role.dart';

class UserConverter {
  // Convert User (Admin or Receptionist or DoctorUser) to JSON
  static Map<String, dynamic> toJson(User user) {
    final baseMap = {
      'id': user.id,
      'username': user.username,
      'password': user.password,
      'role': user.role.name,
      'createdAt': user.createdAt.toIso8601String(),
    };

    if (user is Admin) {
      return {...baseMap, 'fullName': user.fullName, 'email': user.email};
    } else if (user is Receptionist) {
      return {
        ...baseMap,
        'fullName': user.fullName,
        'phoneNumber': user.phoneNumber,
        'createdBy': user.createdBy,
      };
    } else if (user is DoctorUser) {
      return {...baseMap, 'fullName': user.fullName, 'doctorId': user.doctorId};
    }

    throw ArgumentError('Unknown user type');
  }

  // Convert JSON to User (Admin or Receptionist or Doctor)
  static User fromJson(Map<String, dynamic> json) {
    final role = UserRole.fromString(json['role']);

    if (role == UserRole.admin) {
      return Admin(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        createdAt: DateTime.parse(json['createdAt']),
        fullName: json['fullName'],
        email: json['email'],
      );
    } else if (role == UserRole.receptionist) {
      return Receptionist(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        createdAt: DateTime.parse(json['createdAt']),
        fullName: json['fullName'],
        phoneNumber: json['phoneNumber'],
        createdBy: json['createdBy'],
      );
    } else if (role == UserRole.doctor) {
      return DoctorUser(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        createdAt: DateTime.parse(json['createdAt']),
        fullName: json['fullName'],
        doctorId: json['doctorId'],
      );
    }

    throw ArgumentError('Invalid user role in JSON');
  }

  // Convert list of users to JSON
  static List<Map<String, dynamic>> toJsonList(List<User> users) {
    return users.map((user) => toJson(user)).toList();
  }

  // Convert JSON list to list of users
  static List<User> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}

import '../../Domain/models/room.dart';
import '../../Domain/enums/room_status.dart';
import '../../Domain/enums/room_type.dart';

class RoomConverter {
  // Convert Room to JSON
  static Map<String, dynamic> toJson(Room room) {
    return {
      'id': room.id,
      'roomNumber': room.roomNumber,
      'type': room.type.name,
      'status': room.status.name,
      'bedCount': room.bedCount,
      'pricePerDay': room.pricePerDay,
      'currentPatientId': room.currentPatientId,
      'createdAt': room.createdAt.toIso8601String(),
    };
  }

  // Convert JSON to Room
  static Room fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['roomNumber'],
      type: RoomType.fromString(json['type']),
      status: RoomStatus.fromString(json['status']),
      bedCount: json['bedCount'],
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      currentPatientId: json['currentPatientId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert list of rooms to JSON
  static List<Map<String, dynamic>> toJsonList(List<Room> rooms) {
    return rooms.map((room) => toJson(room)).toList();
  }

  // Convert JSON list to list of rooms
  static List<Room> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}

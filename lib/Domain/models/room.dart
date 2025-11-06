import '../enums/room_status.dart';
import '../enums/room_type.dart';

class Room {
  final String id;
  final String roomNumber;
  final RoomType type;
  RoomStatus status;
  final int bedCount;
  String? patientId;

  Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    this.status = RoomStatus.available,
    required this.bedCount,
    this.patientId,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['roomNumber'],
      type: RoomType.values.firstWhere((e) => e.name == json['type']),
      status: RoomStatus.values.firstWhere((e) => e.name == json['status']),
      bedCount: json['bedCount'] ?? json['capacity'] ?? 1,
      patientId: json['patientId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'type': type.name,
      'status': status.name,
      'bedCount': bedCount,
      'patientId': patientId,
    };
  }

  void displayInfo() {
    print('Room ID: $id');
    print('Room Number: $roomNumber');
    print('Type: ${type.name}');
    print('Status: ${status.name}');
    print('Bed Count: $bedCount');
    if (patientId != null) {
      print('Assigned Patient: $patientId');
    }
  }
}

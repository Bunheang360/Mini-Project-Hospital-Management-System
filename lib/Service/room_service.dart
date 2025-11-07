import '../Domain/models/room.dart';
import '../Domain/enums/room_type.dart';
import '../Domain/enums/room_status.dart';
import '../Data/Repositories/room_repository.dart';

class RoomService {
  final RoomRepository _repository;

  RoomService(this._repository);

  bool addRoom({
    required String id,
    required String roomNumber,
    required RoomType type,
    required int bedCount,
    RoomStatus status = RoomStatus.available,
  }) {
    if (_repository.getRoomById(id) != null) {
      return false;
    }

    final room = Room(
      id: id,
      roomNumber: roomNumber,
      type: type,
      status: status,
      bedCount: bedCount,
    );

    if (!room.validate()) {
      return false;
    }

    _repository.addRoom(room);
    return true;
  }

  List<Room> getAllRooms() {
    return _repository.getAllRooms();
  }

  Room? getRoomById(String id) {
    return _repository.getRoomById(id);
  }

  Room? getRoomByRoomNumber(String roomNumber) {
    final rooms = _repository.getAllRooms();
    try {
      return rooms.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  List<Room> getAvailableRooms() {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.isAvailable()).toList();
  }

  List<Room> getRoomsByType(RoomType type) {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.type == type).toList();
  }

  List<Room> getRoomsByStatus(RoomStatus status) {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.status == status).toList();
  }

  List<Room> getOccupiedRooms() {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.isOccupied()).toList();
  }

  bool assignPatientToRoom(String roomId, String patientId) {
    final room = _repository.getRoomById(roomId);
    if (room == null) {
      return false;
    }

    if (!room.isAvailable()) {
      return false;
    }

    room.status = RoomStatus.occupied;
    room.patientId = patientId;
    _repository.updateRoom(room);
    return true;
  }

  bool releaseRoom(String roomId) {
    final room = _repository.getRoomById(roomId);
    if (room == null) {
      return false;
    }

    room.status = RoomStatus.available;
    room.patientId = null;
    _repository.updateRoom(room);
    return true;
  }

  bool updateRoomStatus(String roomNumber, RoomStatus status) {
    final room = getRoomByRoomNumber(roomNumber);
    if (room == null) {
      return false;
    }

    room.status = status;
    _repository.updateRoom(room);
    return true;
  }

  bool deleteRoom(String roomNumber) {
    final room = getRoomByRoomNumber(roomNumber);
    if (room == null) {
      return false;
    }

    // Don't delete occupied rooms
    if (room.status == RoomStatus.occupied) {
      return false;
    }

    _repository.deleteRoom(room.id);
    return true;
  }

  Map<RoomStatus, int> getRoomStatistics() {
    final rooms = _repository.getAllRooms();
    final stats = <RoomStatus, int>{};
    
    for (var status in RoomStatus.values) {
      stats[status] = rooms.where((r) => r.status == status).length;
    }
    
    return stats;
  }

  int getTotalBedCount() {
    final rooms = _repository.getAllRooms();
    return rooms.fold(0, (sum, room) => sum + room.bedCount);
  }

  int getAvailableBedCount() {
    final rooms = _repository.getAllRooms();
    return rooms
        .where((r) => r.isAvailable())
        .fold(0, (sum, room) => sum + room.bedCount);
  }
}
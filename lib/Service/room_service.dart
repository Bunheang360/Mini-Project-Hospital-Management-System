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

    if (bedCount <= 0) {
      return false;
    }

    final room = Room(
      id: id,
      roomNumber: roomNumber,
      type: type,
      status: status,
      bedCount: bedCount,
    );

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
    return _repository.getRoomByRoomNumber(roomNumber);
  }

  List<Room> getAvailableRooms() {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.status == RoomStatus.available).toList();
  }

  List<Room> getRoomsByType(RoomType type) {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.type == type).toList();
  }

  List<Room> getRoomsByStatus(RoomStatus status) {
    final rooms = _repository.getAllRooms();
    return rooms.where((r) => r.status == status).toList();
  }

  bool assignPatientToRoom(String roomId, String patientId) {
    final room = _repository.getRoomById(roomId);
    if (room == null) {
      return false;
    }

    if (room.status != RoomStatus.available) {
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
    final room = _repository.getRoomByRoomNumber(roomNumber);
    if (room == null) {
      return false;
    }

    room.status = status;
    _repository.updateRoom(room);
    return true;
  }

  bool deleteRoom(String roomNumber) {
    final room = _repository.getRoomByRoomNumber(roomNumber);
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
    return {
      RoomStatus.available: rooms
          .where((r) => r.status == RoomStatus.available)
          .length,
      RoomStatus.occupied: rooms
          .where((r) => r.status == RoomStatus.occupied)
          .length,
      RoomStatus.maintenance: rooms
          .where((r) => r.status == RoomStatus.maintenance)
          .length,
    };
  }

  int getTotalBedCount() {
    final rooms = _repository.getAllRooms();
    return rooms.fold(0, (sum, room) => sum + room.bedCount);
  }

  int getAvailableBedCount() {
    final availableRooms = getAvailableRooms();
    return availableRooms.fold(0, (sum, room) => sum + room.bedCount);
  }
}

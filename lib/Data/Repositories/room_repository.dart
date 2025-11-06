import '../../Domain/models/room.dart';
import '../Storage/json_storage.dart';

class RoomRepository {
  final JsonStorage _storage = JsonStorage('rooms.json');

  void addRoom(Room room) {
    final rooms = _storage.read();
    rooms.add(room.toJson());
    _storage.write(rooms);
  }

  List<Room> getAllRooms() {
    final rooms = _storage.read();
    return rooms.map((json) => Room.fromJson(json)).toList();
  }

  Room? getRoomById(String id) {
    final rooms = getAllRooms();
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Room? getRoomByRoomNumber(String roomNumber) {
    final rooms = getAllRooms();
    try {
      return rooms.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  void updateRoom(Room room) {
    final rooms = _storage.read();
    final index = rooms.indexWhere((r) => r['id'] == room.id);
    if (index != -1) {
      rooms[index] = room.toJson();
      _storage.write(rooms);
    }
  }

  void deleteRoom(String id) {
    final rooms = _storage.read();
    rooms.removeWhere((r) => r['id'] == id);
    _storage.write(rooms);
  }
}

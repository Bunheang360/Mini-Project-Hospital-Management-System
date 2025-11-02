import '../../Domain/models/room.dart';
import '../../Domain/enums/room_status.dart';
import '../../Domain/enums/room_type.dart';
import '../Storage/json_storage.dart';
import '../JsonConverter/room_converter.dart';

class RoomRepository {
  final JsonStorage _storage;
  final String _fileName = 'rooms.json';

  RoomRepository(this._storage);

  // Get all rooms
  Future<List<Room>> getAll() async {
    final jsonList = await _storage.readJsonFile(_fileName);
    return RoomConverter.fromJsonList(jsonList);
  }

  // Get room by ID
  Future<Room?> getById(String id) async {
    final rooms = await getAll();
    try {
      return rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get room by room number
  Future<Room?> getByRoomNumber(String roomNumber) async {
    final rooms = await getAll();
    try {
      return rooms.firstWhere((room) => room.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  // Get rooms by status
  Future<List<Room>> getByStatus(RoomStatus status) async {
    final rooms = await getAll();
    return rooms.where((room) => room.status == status).toList();
  }

  // Get rooms by type
  Future<List<Room>> getByType(RoomType type) async {
    final rooms = await getAll();
    return rooms.where((room) => room.type == type).toList();
  }

  // Get available rooms
  Future<List<Room>> getAvailableRooms() async {
    return await getByStatus(RoomStatus.available);
  }

  // Save (create or update) a room
  Future<void> save(Room room) async {
    final rooms = await getAll();

    // Check if room already exists
    final existingIndex = rooms.indexWhere((r) => r.id == room.id);

    if (existingIndex != -1) {
      // Update existing room
      rooms[existingIndex] = room;
    } else {
      // Add new room
      rooms.add(room);
    }

    final jsonList = RoomConverter.toJsonList(rooms);
    await _storage.writeJsonFile(_fileName, jsonList);
  }

  // Delete room by ID
  Future<bool> delete(String id) async {
    final rooms = await getAll();
    final initialLength = rooms.length;

    rooms.removeWhere((room) => room.id == id);

    if (rooms.length < initialLength) {
      final jsonList = RoomConverter.toJsonList(rooms);
      await _storage.writeJsonFile(_fileName, jsonList);
      return true;
    }

    return false;
  }

  // Check if room number exists
  Future<bool> roomNumberExists(String roomNumber) async {
    final room = await getByRoomNumber(roomNumber);
    return room != null;
  }

  // Clear all rooms
  Future<void> clear() async {
    await _storage.clearJsonFile(_fileName);
  }
}

import '../Domain/models/room.dart';
import '../Domain/enums/room_status.dart';
import '../Domain/enums/room_type.dart';
import '../Data/Repositories/room_repository.dart';
import '../Data/Repositories/patient_repository.dart';

class RoomService {
  final RoomRepository _roomRepository;
  final PatientRepository _patientRepository;

  RoomService(this._roomRepository, this._patientRepository);

  // Generate unique ID
  String _generateId() {
    return 'room_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Create new room
  Future<Room> createRoom({
    required String roomNumber,
    required RoomType type,
    required int bedCount,
    required double pricePerDay,
  }) async {
    // Validate inputs
    if (roomNumber.isEmpty) {
      throw ArgumentError('Room number cannot be empty');
    }

    if (bedCount <= 0 || bedCount > 10) {
      throw ArgumentError('Bed count must be between 1 and 10');
    }

    if (pricePerDay < 0) {
      throw ArgumentError('Price per day cannot be negative');
    }

    // Check if room number already exists
    if (await _roomRepository.roomNumberExists(roomNumber)) {
      throw Exception('Room number already exists');
    }

    // Create room
    final room = Room(
      id: _generateId(),
      roomNumber: roomNumber,
      type: type,
      status: RoomStatus.available,
      bedCount: bedCount,
      pricePerDay: pricePerDay,
      createdAt: DateTime.now(),
    );

    // Save to repository
    await _roomRepository.save(room);

    return room;
  }

  // Get all rooms
  Future<List<Room>> getAllRooms() {
    return _roomRepository.getAll();
  }

  // Get room by ID
  Future<Room?> getRoomById(String id) {
    return _roomRepository.getById(id);
  }

  // Get room by room number
  Future<Room?> getRoomByRoomNumber(String roomNumber) {
    return _roomRepository.getByRoomNumber(roomNumber);
  }

  // Get available rooms
  Future<List<Room>> getAvailableRooms() {
    return _roomRepository.getAvailableRooms();
  }

  // Get rooms by type
  Future<List<Room>> getRoomsByType(RoomType type) {
    return _roomRepository.getByType(type);
  }

  // Get rooms by status
  Future<List<Room>> getRoomsByStatus(RoomStatus status) {
    return _roomRepository.getByStatus(status);
  }

  // Update room
  Future<void> updateRoom(Room room) async {
    // Validate
    if (!room.isValidRoomNumber()) {
      throw ArgumentError('Invalid room number');
    }

    if (!room.isValidBedCount()) {
      throw ArgumentError('Invalid bed count');
    }

    if (!room.isValidPrice()) {
      throw ArgumentError('Invalid price');
    }

    return _roomRepository.save(room);
  }

  // Assign patient to room
  Future<void> assignPatientToRoom(String roomId, String patientId) async {
    // Get room
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Verify patient exists
    final patient = await _patientRepository.getById(patientId);
    if (patient == null) {
      throw Exception('Patient not found');
    }

    // Check if room is available
    if (!room.canAssignPatient()) {
      throw Exception('Room is not available for assignment');
    }

    // Assign patient
    room.assignPatient(patientId);

    // Save updated room
    return _roomRepository.save(room);
  }

  // Release patient from room
  Future<void> releasePatientFromRoom(String roomId) async {
    // Get room
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Release patient
    room.releasePatient();

    // Save updated room
    return _roomRepository.save(room);
  }

  // Set room to maintenance
  Future<void> setRoomToMaintenance(String roomId) async {
    // Get room
    final room = await _roomRepository.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Set to maintenance
    room.setMaintenance();

    // Save updated room
    return _roomRepository.save(room);
  }

  // Delete room
  Future<bool> deleteRoom(String id) async {
    final room = await _roomRepository.getById(id);

    if (room == null) {
      throw Exception('Room not found');
    }

    // Check if room is occupied
    if (room.status == RoomStatus.occupied) {
      throw Exception('Cannot delete occupied room');
    }

    return _roomRepository.delete(id);
  }

  // Get room count
  Future<int> getRoomCount() async {
    final rooms = await getAllRooms();
    return rooms.length;
  }

  // Get available room count
  Future<int> getAvailableRoomCount() async {
    final availableRooms = await getAvailableRooms();
    return availableRooms.length;
  }

  // Get occupied room count
  Future<int> getOccupiedRoomCount() async {
    final occupiedRooms = await getRoomsByStatus(RoomStatus.occupied);
    return occupiedRooms.length;
  }
}

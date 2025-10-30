import '../enums/RoomStatus.dart';
import '../enums/RoomType.dart';

class Room {
  final String id;
  final String roomNumber;
  final RoomType type;
  RoomStatus status;
  final int bedCount;
  final double pricePerDay;
  String? currentPatientId; // Null if not occupied
  final DateTime createdAt;

  Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.status,
    required this.bedCount,
    required this.pricePerDay,
    this.currentPatientId,
    required this.createdAt,
  });

  // Validation methods
  bool isValidRoomNumber() {
    return roomNumber.isNotEmpty;
  }

  bool isValidBedCount() {
    return bedCount > 0 && bedCount <= 10;
  }

  bool isValidPrice() {
    return pricePerDay >= 0;
  }

  // Business logic methods
  bool isAvailable() {
    return status == RoomStatus.available && currentPatientId == null;
  }

  bool canAssignPatient() {
    return isAvailable();
  }

  void assignPatient(String patientId) {
    if (!canAssignPatient()) {
      throw StateError('Room is not available for assignment');
    }
    currentPatientId = patientId;
    status = RoomStatus.occupied;
  }

  void releasePatient() {
    if (status != RoomStatus.occupied) {
      throw StateError('Room is not occupied');
    }
    currentPatientId = null;
    status = RoomStatus.available;
  }

  void setMaintenance() {
    if (status == RoomStatus.occupied) {
      throw StateError('Cannot set occupied room to maintenance');
    }
    status = RoomStatus.maintenance;
    currentPatientId = null;
  }

  String getDisplayInfo() {
    return 'Room $roomNumber (${type.displayName}) - ${status.displayName} - \$${pricePerDay.toStringAsFixed(2)}/day';
  }

  @override
  String toString() {
    return 'Room(id: $id, number: $roomNumber, type: ${type.displayName}, '
        'status: ${status.displayName}, beds: $bedCount, price: \$${pricePerDay.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
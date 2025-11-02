enum RoomStatus {
  available,
  occupied,
  maintenance;

  String get displayName {
    switch (this) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.maintenance:
        return 'Under Maintenance';
    }
  }

  static RoomStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return RoomStatus.available;
      case 'occupied':
        return RoomStatus.occupied;
      case 'maintenance':
        return RoomStatus.maintenance;
      default:
        throw ArgumentError('Invalid room status: $status');
    }
  }
}
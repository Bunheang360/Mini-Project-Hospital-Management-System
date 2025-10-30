enum RoomType {
  icu,
  general,
  private,
  emergency;

  String get displayName {
    switch (this) {
      case RoomType.icu:
        return 'ICU (Intensive Care Unit)';
      case RoomType.general:
        return 'General Ward';
      case RoomType.private:
        return 'Private Room';
      case RoomType.emergency:
        return 'Emergency Room';
    }
  }

  static RoomType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'icu':
        return RoomType.icu;
      case 'general':
        return RoomType.general;
      case 'private':
        return RoomType.private;
      case 'emergency':
        return RoomType.emergency;
      default:
        throw ArgumentError('Invalid room type: $type');
    }
  }
}
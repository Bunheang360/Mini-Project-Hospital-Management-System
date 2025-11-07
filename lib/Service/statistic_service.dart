import '../Domain/enums/appointment_status.dart';
import '../Domain/enums/room_status.dart';
import 'user_service.dart';
import 'patient_service.dart';
import 'appointment_service.dart';
import 'room_service.dart';

class StatisticsService {
  final UserService _userService;
  final PatientService _patientService;
  final AppointmentService _appointmentService;
  final RoomService _roomService;

  StatisticsService(
    this._userService,
    this._patientService,
    this._appointmentService,
    this._roomService,
  );

  void displayAllStatistics() {
    print('\n${'=' * 50}');
    print('HOSPITAL STATISTICS');
    print('=' * 50);

    // Staff statistics
    final doctors = _userService.getAllDoctors();
    final receptionists = _userService.getAllReceptionists();
    print('\nSTAFF:');
    print('  Doctors: ${doctors.length}');
    print('  Receptionists: ${receptionists.length}');
    print(
      '  Total Staff: ${doctors.length + receptionists.length + 1}',
    );

    // Patient statistics
    final patients = _patientService.getAllPatients();
    print('\nPATIENTS:');
    print('  Total Patients: ${patients.length}');

    // Appointment statistics
    final appointmentStats = _appointmentService.getAppointmentStatistics();
    final totalAppointments = appointmentStats.values.fold(
      0,
      (sum, count) => sum + count,
    );

    print('\nAPPOINTMENTS:');
    print('  Total Appointments: $totalAppointments');
    print('  Scheduled: ${appointmentStats[AppointmentStatus.scheduled]}');
    print('  Completed: ${appointmentStats[AppointmentStatus.completed]}');
    print('  Cancelled: ${appointmentStats[AppointmentStatus.cancelled]}');

    // Room statistics
    final roomStats = _roomService.getRoomStatistics();
    final totalRooms = roomStats.values.fold(0, (sum, count) => sum + count);
    final totalBedCount = _roomService.getTotalBedCount();
    final availableBedCount = _roomService.getAvailableBedCount();

    print('\nROOMS:');
    print('  Total Rooms: $totalRooms');
    print('  Available: ${roomStats[RoomStatus.available]}');
    print('  Occupied: ${roomStats[RoomStatus.occupied]}');
    print('  Under Maintenance: ${roomStats[RoomStatus.maintenance]}');
    print('  Total Bed Count: $totalBedCount beds');
    print('  Available Bed Count: $availableBedCount beds');

    print('=' * 50 + '\n');
  }

  Map<String, dynamic> getDetailedStatistics() {
    return {
      'staff': {
        'doctors': _userService.getAllDoctors().length,
        'receptionists': _userService.getAllReceptionists().length,
      },
      'patients': {'total': _patientService.getAllPatients().length},
      'appointments': _appointmentService.getAppointmentStatistics(),
      'rooms': {
        'status': _roomService.getRoomStatistics(),
        'capacity': {
          'total': _roomService.getTotalBedCount(),
          'available': _roomService.getAvailableBedCount(),
        },
      },
    };
  }
}

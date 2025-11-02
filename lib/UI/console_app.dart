import '../Domain/services/auth_service.dart';
import '../Domain/services/user_service.dart';
import '../Domain/services/doctor_service.dart';
import '../Domain/services/patient_service.dart';
import '../Domain/services/room_service.dart';
import '../Domain/services/appointment_service.dart';
import '../Data/Repositories/user_repository.dart';
import '../Data/Repositories/doctor_repository.dart';
import '../Data/Repositories/patient_repository.dart';
import '../Data/Repositories/room_repository.dart';
import '../Data/Repositories/appointment_repository.dart';
import '../Data/Storage/json_storage.dart';
import 'menus/main_menu.dart';
import 'menus/admin_menu.dart';
import 'menus/receptionist_menu.dart';
import 'menus/doctor_menu.dart';

class ConsoleApp {
  late final JsonStorage _storage;

  // Repositories
  late final UserRepository _userRepository;
  late final DoctorRepository _doctorRepository;
  late final PatientRepository _patientRepository;
  late final RoomRepository _roomRepository;
  late final AppointmentRepository _appointmentRepository;

  // Services
  late final AuthService _authService;
  late final UserService _userService;
  late final DoctorService _doctorService;
  late final PatientService _patientService;
  late final RoomService _roomService;
  late final AppointmentService _appointmentService;

  // Menus
  late final AdminMenu _adminMenu;
  late final ReceptionistMenu _receptionistMenu;
  late final DoctorMenu _doctorMenu;
  late final MainMenu _mainMenu;

  ConsoleApp() {
    _initializeApp();
  }

  void _initializeApp() {
    // Initialize storage
    _storage = JsonStorage(dataDirectory: 'data');

    // Initialize repositories
    _userRepository = UserRepository(_storage);
    _doctorRepository = DoctorRepository(_storage);
    _patientRepository = PatientRepository(_storage);
    _roomRepository = RoomRepository(_storage);
    _appointmentRepository = AppointmentRepository(_storage);

    // Initialize services
    _authService = AuthService(_userRepository);
    _userService = UserService(_userRepository);
    _doctorService = DoctorService(_doctorRepository);
    _patientService = PatientService(_patientRepository);
    _roomService = RoomService(_roomRepository, _patientRepository);
    _appointmentService = AppointmentService(
      _appointmentRepository,
      _patientRepository,
      _doctorRepository,
      _roomRepository,
    );

    // Initialize menus
    _adminMenu = AdminMenu(
      _authService,
      _userService,
      _doctorService,
      _roomService,
      _patientService,
      _appointmentService,
    );

    _receptionistMenu = ReceptionistMenu(
      _authService,
      _patientService,
      _appointmentService,
      _doctorService,
      _roomService,
    );

    _doctorMenu = DoctorMenu(
      _authService,
      _doctorService,
      _appointmentService,
      _patientService,
    );

    _mainMenu = MainMenu(
      _authService,
      _adminMenu,
      _receptionistMenu,
      _doctorMenu,
    );
  }

  Future<void> run() async {
    await _authService.initialize();

    await _mainMenu.show();
  }
}

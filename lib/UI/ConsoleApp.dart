import '../Domain/services/AuthService.dart';
import '../Domain/services/UserService.dart';
import '../Domain/services/DoctorService.dart';
import '../Domain/services/PatientService.dart';
import '../Domain/services/RoomService.dart';
import '../Domain/services/AppointmentService.dart';
import '../Data/Repositories/UserRepository.dart';
import '../Data/Repositories/DoctorRepository.dart';
import '../Data/Repositories/PatientRepository.dart';
import '../Data/Repositories/RoomRepository.dart';
import '../Data/Repositories/AppointmentRepository.dart';
import '../Data/Storage/JsonStorage.dart';
import 'menus/MainMenu.dart';
import 'menus/AdminMenu.dart';
import 'menus/ReceptionistMenu.dart';

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
    );

    // Initialize menus
    _adminMenu = AdminMenu(
      _authService,
      _userService,
      _doctorService,
      _roomService,
    );

    _receptionistMenu = ReceptionistMenu(
      _authService,
      _patientService,
      _appointmentService,
      _doctorService,
    );

    _mainMenu = MainMenu(_authService, _adminMenu, _receptionistMenu);
  }

  Future<void> run() async {
    await _authService.initialize();

    await _mainMenu.show();
  }
}

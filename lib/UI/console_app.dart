import '../Data/Repositories/user_repository.dart';
import '../Data/Repositories/patient_repository.dart';
import '../Data/Repositories/appointment_repository.dart';
import '../Data/Repositories/room_repository.dart';
import '../Service/auth_service.dart';
import '../Service/user_service.dart';
import '../Service/patient_service.dart';
import '../Service/appointment_service.dart';
import '../Service/room_service.dart';
import '../Service/statistic_service.dart';
import 'menus/main_menu.dart';

class ConsoleApp {
  late final AuthenticationService authService;
  late final UserService userService;
  late final PatientService patientService;
  late final AppointmentService appointmentService;
  late final RoomService roomService;
  late final StatisticsService statisticsService;
  late final MainMenu mainMenu;

  ConsoleApp() {
    _initializeServices();
  }

  void _initializeServices() {
    // Initialize repositories
    final userRepository = UserRepository();
    final patientRepository = PatientRepository();
    final appointmentRepository = AppointmentRepository();
    final roomRepository = RoomRepository();

    // Initialize services
    authService = AuthenticationService(userRepository);
    userService = UserService(userRepository);
    patientService = PatientService(patientRepository);
    appointmentService = AppointmentService(
      appointmentRepository,
      patientRepository,
      userRepository,
    );
    roomService = RoomService(roomRepository);
    statisticsService = StatisticsService(
      userService,
      patientService,
      appointmentService,
      roomService,
    );

    // Initialize main menu with all services
    mainMenu = MainMenu(
      authService,
      userService,
      patientService,
      appointmentService,
      roomService,
      statisticsService,
    );
  }

  void run() {
    mainMenu.display();
  }
}

void main() {
  final app = ConsoleApp();
  app.run();
}

// lib/UI/menus/main_menu.dart
import 'dart:io';
import '../../Service/auth_service.dart';
import '../../Service/user_service.dart';
import '../../Service/patient_service.dart';
import '../../Service/appointment_service.dart';
import '../../Service/room_service.dart';
import '../../Service/statistic_service.dart';
import '../../Domain/enums/user_role.dart';
import '../utils/console_utils.dart';
import 'admin_menu.dart';
import 'receptionist_menu.dart';
import 'doctor_menu.dart';

class MainMenu {
  final AuthenticationService _authService;
  final UserService _userService;
  final PatientService _patientService;
  final AppointmentService _appointmentService;
  final RoomService _roomService;
  final StatisticsService _statisticsService;

  MainMenu(
    this._authService,
    this._userService,
    this._patientService,
    this._appointmentService,
    this._roomService,
    this._statisticsService,
  );

  void display() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n${'=' * 50}');
      print('HOSPITAL MANAGEMENT SYSTEM');
      print('=' * 50);
      print('1. Login');
      print('2. Exit');
      print('=' * 50);
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _login();
          break;
        case '2':
          ConsoleUtils.clearScreen();
          print('\nThank you for using Hospital Management System!');
          exit(0);
        default:
          print('\nInvalid option! Please try again.');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _login() {
    ConsoleUtils.clearScreen();
    // Show user type selection
    print('\n--- SELECT USER TYPE ---');
    print('1. Admin');
    print('2. Doctor');
    print('3. Receptionist');
    print('=' * 50);
    stdout.write('Select user type: ');

    final roleChoice = stdin.readLineSync();

    UserRole? selectedRole;
    switch (roleChoice) {
      case '1':
        selectedRole = UserRole.admin;
        break;
      case '2':
        selectedRole = UserRole.doctor;
        break;
      case '3':
        selectedRole = UserRole.receptionist;
        break;
      default:
        print('\nInvalid option! Please try again.');
        sleep(Duration(seconds: 1));
        return;
    }

    ConsoleUtils.clearScreen();
    // Now ask for credentials
    print('\n--- LOGIN ---');
    stdout.write('Username: ');
    final username = stdin.readLineSync() ?? '';
    stdout.write('Password: ');
    final password = stdin.readLineSync() ?? '';

    final user = _authService.login(username, password);

    if (user == null) {
      print('\nInvalid username or password!');
      sleep(Duration(seconds: 2));
      return;
    }

    // Verify the role matches
    if (user.role != selectedRole) {
      print(
        '\nError: You selected ${selectedRole.toString().split('.').last} but logged in as ${user.role.toString().split('.').last}!',
      );
      sleep(Duration(seconds: 2));
      return;
    }

    print('\nLogin successful! Welcome, ${user.name}');
    sleep(Duration(seconds: 1));

    switch (user.role) {
      case UserRole.admin:
        final adminMenu = AdminMenu(
          user,
          _userService,
          _roomService,
          _statisticsService,
        );
        adminMenu.display();
        break;
      case UserRole.receptionist:
        final receptionistMenu = ReceptionistMenu(
          user,
          _patientService,
          _appointmentService,
          _userService,
          _roomService,
        );
        receptionistMenu.display();
        break;
      case UserRole.doctor:
        final doctorMenu = DoctorMenu(
          user,
          _appointmentService,
          _patientService,
        );
        doctorMenu.display();
        break;
    }
  }
}

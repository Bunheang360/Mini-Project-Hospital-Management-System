import 'dart:io';
import '../../Domain/models/user.dart';
import '../../Domain/enums/appointment_status.dart';
import '../../Service/appointment_service.dart';
import '../../Service/patient_service.dart';
import '../utils/console_utils.dart';

class DoctorMenu {
  final User _currentUser;
  final AppointmentService _appointmentService;
  final PatientService _patientService;

  DoctorMenu(this._currentUser, this._appointmentService, this._patientService);

  void display() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n${'=' * 50}');
      print('DOCTOR MENU - ${_currentUser.name}');
      print('=' * 50);
      print('1. View Upcoming Appointments');
      print('2. View All My Appointments');
      print('3. Update Appointment Status');
      print('4. Logout');
      print('=' * 50);
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _viewUpcomingAppointments();
          stdout.write('\nPress Enter to continue...');
          stdin.readLineSync();
          break;
        case '2':
          _viewAllMyAppointments();
          stdout.write('\nPress Enter to continue...');
          stdin.readLineSync();
          break;
        case '3':
          _updateAppointmentStatus();
          break;
        case '4':
          print('\nLogging out...');
          sleep(Duration(seconds: 1));
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _viewUpcomingAppointments() {
    final appointments = _appointmentService.getUpcomingAppointments(
      _currentUser.id,
    );
    if (appointments.isEmpty) {
      print('\nNo upcoming appointments.');
      return;
    }
    print('\n--- UPCOMING APPOINTMENTS ---');
    _displayAppointments(appointments);
  }

  void _viewAllMyAppointments() {
    final appointments = _appointmentService.getAppointmentsByDoctorId(
      _currentUser.id,
    );
    if (appointments.isEmpty) {
      print('\nNo appointments found.');
      return;
    }
    appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    print('\n--- ALL MY APPOINTMENTS ---');
    _displayAppointments(appointments);
  }

  void _displayAppointments(List appointments) {
    for (var appointment in appointments) {
      print('\n${'-' * 40}');
      appointment.displayInfo();

      final patient = _patientService.getPatientById(appointment.patientId);
      if (patient != null) {
        print('Patient Name: ${patient.name}');
        print('Patient Phone: ${patient.phoneNumber}');
        print('Patient Age: ${patient.age}');
        if (patient.medicalHistory != null) {
          print('Medical History: ${patient.medicalHistory}');
        }
      }
    }
    print('-' * 40);
  }

  void _updateAppointmentStatus() {
    // Get all appointments for this doctor
    final allAppointments = _appointmentService.getAppointmentsByDoctorId(
      _currentUser.id,
    );

    // Filter only scheduled appointments
    final scheduledAppointments = allAppointments
        .where((a) => a.status == AppointmentStatus.scheduled)
        .toList();

    if (scheduledAppointments.isEmpty) {
      print('\nNo scheduled appointments found.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    // Display scheduled appointments
    print('\n--- SCHEDULED APPOINTMENTS ---');
    for (int i = 0; i < scheduledAppointments.length; i++) {
      final appointment = scheduledAppointments[i];
      print('\n${i + 1}. Appointment ID: ${appointment.id}');
      print('   Date: ${appointment.dateTime}');
      print('   Reason: ${appointment.reason}');

      final patient = _patientService.getPatientById(appointment.patientId);
      if (patient != null) {
        print('   Patient: ${patient.name}');
        print('   Phone: ${patient.phoneNumber}');
      }
    }
    print('0. Cancel');
    print('-' * 40);

    stdout.write(
      '\nSelect appointment (1-${scheduledAppointments.length}, 0 to cancel): ',
    );
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 0 || choice > scheduledAppointments.length) {
      print('Invalid selection!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    if (choice == 0) {
      print('Operation cancelled.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    final selectedAppointment = scheduledAppointments[choice - 1];

    print('\nSelected Appointment:');
    selectedAppointment.displayInfo();

    print('\nSelect New Status:');
    print('1. Completed');
    print('2. Cancelled');
    stdout.write('Choice: ');

    final statusChoice = stdin.readLineSync();

    if (statusChoice == '1') {
      stdout.write('Enter consultation notes: ');
      final notes = stdin.readLineSync();
      final success = _appointmentService.updateAppointmentStatus(
        selectedAppointment.id,
        AppointmentStatus.completed,
        notes,
      );
      print(
        success ? '\n✓ Appointment marked as completed!' : '\n✗ Update failed!',
      );
    } else if (statusChoice == '2') {
      stdout.write('Enter reason for cancellation: ');
      final notes = stdin.readLineSync();
      final success = _appointmentService.updateAppointmentStatus(
        selectedAppointment.id,
        AppointmentStatus.cancelled,
        notes,
      );
      print(success ? '\n✓ Appointment cancelled!' : '\n✗ Update failed!');
    } else {
      print('Invalid choice!');
    }

    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }
}

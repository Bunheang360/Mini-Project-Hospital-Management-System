import '../../Service/auth_service.dart';
import '../../Service/doctor_service.dart';
import '../../Service/appointment_service.dart';
import '../../Service/patient_service.dart';
import '../../Domain/enums/appointment_status.dart';
import '../../Domain/models/doctor_user.dart';
import '../utils/console_helper.dart';
import '../utils/input_valid_utils.dart';

class DoctorMenu {
  final AuthService _authService;
  final DoctorService _doctorService;
  final AppointmentService _appointmentService;
  final PatientService _patientService;

  DoctorMenu(
    this._authService,
    this._doctorService,
    this._appointmentService,
    this._patientService,
  );

  Future<void> show() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Doctor Dashboard');

      final user = _authService.currentUser as DoctorUser?;
      if (user == null) {
        ConsoleHelper.printError('User not found');
        return;
      }

      // Get doctor details
      final doctor = await _doctorService.getDoctorById(user.doctorId);
      if (doctor == null) {
        ConsoleHelper.printError('Doctor profile not found');
        return;
      }

      print('Logged in as: Dr. ${doctor.name}');
      print('Department: ${doctor.department}');
      print('Shift: ${doctor.shift}\n');

      ConsoleHelper.printMenu([
        'View My Appointments',
        'Update Appointment Status',
        'View Patient Details',
        'Logout',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        4,
        allowZero: false,
      );

      switch (choice) {
        case 1:
          await _viewMyAppointments(user.doctorId);
          break;
        case 2:
          await _updateAppointmentStatus(user.doctorId);
          break;
        case 3:
          await _viewPatientDetails();
          break;
        case 4:
          return; // Logout
      }
    }
  }

  // View doctor's own appointments
  Future<void> _viewMyAppointments(String doctorId) async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printHeader('My Appointments');

    try {
      final allAppointments = await _appointmentService.getAllAppointments();
      final myAppointments = allAppointments
          .where(
            (apt) =>
                apt.doctorId == doctorId &&
                apt.status == AppointmentStatus.scheduled,
          )
          .toList();

      if (myAppointments.isEmpty) {
        ConsoleHelper.printInfo('No scheduled appointments found');
      } else {
        // Sort by date
        myAppointments.sort(
          (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
        );

        print(''); // spacing
        for (var appointment in myAppointments) {
          final patient = await _patientService.getPatientById(
            appointment.patientId,
          );
          final patientName = patient?.name ?? 'Unknown Patient';
          final dateStr = ConsoleHelper.formatDate(appointment.appointmentDate);
          final timeStr = ConsoleHelper.formatTime(appointment.appointmentDate);

          // Print appointment with box
          print(
            '┌─────────────────────────────────────────────────────────────',
          );
          print('│ Date: $dateStr at $timeStr');
          print('│ Patient: $patientName (Age: ${patient?.age ?? 'N/A'})');
          print('│ Status: ${appointment.status.displayName}');
          print('│ Reason: ${appointment.reason}');
          if (appointment.notes != null && appointment.notes!.isNotEmpty) {
            print('│ Notes: ${appointment.notes}');
          }
          print(
            '└─────────────────────────────────────────────────────────────',
          );
          print('');
        }

        print('Total Scheduled Appointments: ${myAppointments.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  // Update appointment status
  Future<void> _updateAppointmentStatus(String doctorId) async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Update Appointment Status');

    try {
      // Show doctor's appointments
      final allAppointments = await _appointmentService.getAllAppointments();
      final myAppointments = allAppointments
          .where(
            (apt) =>
                apt.doctorId == doctorId &&
                apt.status == AppointmentStatus.scheduled,
          )
          .toList();

      if (myAppointments.isEmpty) {
        ConsoleHelper.printInfo('No scheduled appointments found');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Sort by appointment date
      myAppointments.sort(
        (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
      );

      print('\nYour Scheduled Appointments:\n');

      for (int i = 0; i < myAppointments.length; i++) {
        final apt = myAppointments[i];
        final patient = await _patientService.getPatientById(apt.patientId);
        final patientName = patient?.name ?? 'Unknown Patient';
        final dateStr = ConsoleHelper.formatDate(apt.appointmentDate);
        final timeStr = ConsoleHelper.formatTime(apt.appointmentDate);

        print('${i + 1}. $dateStr at $timeStr');
        print('   Patient: $patientName');
        print('   Reason: ${apt.reason}');
        print('');
      }

      final choice = InputValidator.readChoiceOrCancel(
        'Select appointment to update',
        myAppointments.length,
      );
      if (choice == null) {
        ConsoleHelper.printInfo('Update cancelled');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final appointment = myAppointments[choice - 1];
      final patient = await _patientService.getPatientById(
        appointment.patientId,
      );
      final patientName = patient?.name ?? 'Unknown Patient';

      print('\n═══════════════════════════════════════');
      print('Selected Appointment:');
      print('Patient: $patientName');
      print('Date: ${ConsoleHelper.formatDate(appointment.appointmentDate)}');
      print('Time: ${ConsoleHelper.formatTime(appointment.appointmentDate)}');
      print('Reason: ${appointment.reason}');
      print('Current Status: ${appointment.status.displayName}');
      print('═══════════════════════════════════════\n');

      print('Update Status to:');
      ConsoleHelper.printMenu(['Completed', 'Cancelled']);

      final statusChoice = InputValidator.readChoice(
        'Select new status',
        2,
        allowZero: false,
      );

      String? notes;
      if (statusChoice == 1) {
        notes = InputValidator.readString(
          'Enter completion notes (optional)',
          allowEmpty: true,
        );
        if (notes.isEmpty) notes = null;
      }

      if (statusChoice == 1) {
        await _appointmentService.completeAppointment(
          appointment.id,
          notes: notes,
        );
        ConsoleHelper.printSuccess('Appointment marked as completed');
      } else {
        await _appointmentService.cancelAppointment(appointment.id);
        ConsoleHelper.printSuccess('Appointment cancelled');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  // View patient details
  Future<void> _viewPatientDetails() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('View Patient Details');

    try {
      print('\nEnter patient name to search (or press Enter to cancel):');
      final searchName = InputValidator.readString(
        'Patient name',
        allowEmpty: true,
      );

      if (searchName.isEmpty) {
        ConsoleHelper.printInfo('Search cancelled');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Search by name
      final allPatients = await _patientService.getAllPatients();
      final patients = allPatients
          .where((p) => p.name.toLowerCase().contains(searchName.toLowerCase()))
          .toList();

      if (patients.isEmpty) {
        ConsoleHelper.printError('No patients found with that name');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      List<dynamic> selectedPatientList = patients;

      if (patients.length > 1) {
        print('\nMultiple patients found:\n');
        for (int i = 0; i < patients.length; i++) {
          final p = patients[i];
          print(
            '${i + 1}. ${p.name} (Age: ${p.age}, Gender: ${p.gender.displayName})',
          );
        }

        final choice = InputValidator.readChoiceOrCancel(
          'Select patient',
          patients.length,
        );
        if (choice == null) {
          ConsoleHelper.printInfo('Selection cancelled');
          ConsoleHelper.pressEnterToContinue();
          return;
        }
        selectedPatientList = [patients[choice - 1]];
      }

      final patient = selectedPatientList[0];

      print('\n═══════════════════════════════════════');
      print('  PATIENT INFORMATION');
      print('═══════════════════════════════════════');
      print('ID: ${patient.id}');
      print('Name: ${patient.name}');
      print('Age: ${patient.age}');
      print('Gender: ${patient.gender.displayName}');
      print('Phone: ${patient.phoneNumber}');
      print('Address: ${patient.address}');
      print('Medical History: ${patient.medicalHistory ?? "None"}');
      print(
        'Registered: ${ConsoleHelper.formatDate(patient.registrationDate)}',
      );
      print('═══════════════════════════════════════');

      // Show patient's appointments with this doctor
      final allAppointments = await _appointmentService.getAllAppointments();
      final patientAppointments = allAppointments
          .where(
            (apt) =>
                apt.patientId == patient.id &&
                apt.doctorId ==
                    (_authService.currentUser as DoctorUser).doctorId,
          )
          .toList();

      if (patientAppointments.isNotEmpty) {
        // Sort by date descending (most recent first)
        patientAppointments.sort(
          (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
        );

        print('\nAppointment History with you:');
        print('─────────────────────────────────────');
        for (var apt in patientAppointments) {
          final dateStr = ConsoleHelper.formatDate(apt.appointmentDate);
          final timeStr = ConsoleHelper.formatTime(apt.appointmentDate);
          print('\n• $dateStr at $timeStr');
          print('  Status: ${apt.status.displayName}');
          print('  Reason: ${apt.reason}');
          if (apt.notes != null && apt.notes!.isNotEmpty) {
            print('  Notes: ${apt.notes}');
          }
        }
        print('─────────────────────────────────────');
        print('Total appointments: ${patientAppointments.length}');
      } else {
        print('\nNo appointment history with this patient');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }
}

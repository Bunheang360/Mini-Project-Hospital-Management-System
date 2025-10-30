import '../../Domain/services/AuthService.dart';
import '../../Domain/services/PatientService.dart';
import '../../Domain/services/AppointmentService.dart';
import '../../Domain/services/DoctorService.dart';
import '../../Domain/enums/Gender.dart';
import '../../Domain/enums/AppointmentStatus.dart';
import '../utils/ConsoleHelper.dart';
import '../utils/InputValidUtils.dart';

class ReceptionistMenu {
  final AuthService _authService;
  final PatientService _patientService;
  final AppointmentService _appointmentService;
  final DoctorService _doctorService;

  ReceptionistMenu(
    this._authService,
    this._patientService,
    this._appointmentService,
    this._doctorService,
  );

  // ========== HELPER FUNCTIONS ==========

  // Helper: Select patient by name search
  Future<String?> _selectPatientByName() async {
    final name = InputValidator.readString('Enter patient name to search');
    final patients = await _patientService.searchPatientsByName(name);

    if (patients.isEmpty) {
      ConsoleHelper.printError('No patients found with that name');
      return null;
    }

    if (patients.length == 1) {
      ConsoleHelper.printSuccess('Found: ${patients[0].name}');
      return patients[0].id;
    }

    // Multiple patients found - let user choose
    print('\nMultiple patients found:');
    for (int i = 0; i < patients.length; i++) {
      print(
        '${i + 1}. ${patients[i].name} (Age: ${patients[i].age}, Phone: ${patients[i].phoneNumber})',
      );
    }
    print('${patients.length + 1}. Cancel');

    final choice = InputValidator.readChoice(
      'Select patient',
      patients.length + 1,
    );
    if (choice == patients.length + 1) return null;

    return patients[choice - 1].id;
  }

  // Helper: Select doctor by name search
  Future<String?> _selectDoctorByName() async {
    final name = InputValidator.readString(
      'Enter doctor name to search (or specialization)',
    );

    // Search by specialization first
    var doctors = await _doctorService.searchBySpecialization(name);

    // If no results, try getting all and filter by name
    if (doctors.isEmpty) {
      final allDoctors = await _doctorService.getAllDoctors();
      doctors = allDoctors
          .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }

    if (doctors.isEmpty) {
      ConsoleHelper.printError('No doctors found');
      return null;
    }

    if (doctors.length == 1) {
      ConsoleHelper.printSuccess(
        'Found: Dr. ${doctors[0].name} (${doctors[0].specialization})',
      );
      return doctors[0].id;
    }

    // Multiple doctors found - let user choose
    print('\nDoctors found:');
    for (int i = 0; i < doctors.length; i++) {
      print(
        '${i + 1}. Dr. ${doctors[i].name} - ${doctors[i].specialization} (${doctors[i].yearsOfExperience} years exp.)',
      );
    }
    print('${doctors.length + 1}. Cancel');

    final choice = InputValidator.readChoice(
      'Select doctor',
      doctors.length + 1,
    );
    if (choice == doctors.length + 1) return null;

    return doctors[choice - 1].id;
  }

  Future<void> show() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Receptionist Dashboard');

      final user = _authService.currentUser;
      print('Logged in as: ${user?.username} (Receptionist)\n');

      ConsoleHelper.printMenu([
        'Manage Patients',
        'Manage Appointments',
        'Logout',
      ]);

      final choice = InputValidator.readChoice('\nEnter your choice', 3);

      switch (choice) {
        case 1:
          await _managePatients();
          break;
        case 2:
          await _manageAppointments();
          break;
        case 3:
          return; // Logout
      }
    }
  }

  // ========== PATIENT MANAGEMENT ==========
  Future<void> _managePatients() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Manage Patients');

      ConsoleHelper.printMenu([
        'Create New Patient',
        'View All Patients',
        'Search Patient by Name',
        'Update Patient',
        'Delete Patient',
        'Back to Main Menu',
      ]);

      final choice = InputValidator.readChoice('\nEnter your choice', 6);

      switch (choice) {
        case 1:
          await _createPatient();
          break;
        case 2:
          await _viewAllPatients();
          break;
        case 3:
          await _searchPatientByName();
          break;
        case 4:
          await _updatePatient();
          break;
        case 5:
          await _deletePatient();
          break;
        case 6:
          return;
      }
    }
  }

  Future<void> _createPatient() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Create New Patient');

    try {
      final name = InputValidator.readString('Patient Name');
      final age = InputValidator.readInt('Age', min: 1, max: 150);

      print('\nGender:');
      ConsoleHelper.printMenu(['Male', 'Female', 'Other']);
      final genderChoice = InputValidator.readChoice('Select gender', 3);
      final gender = Gender.values[genderChoice - 1];

      final phoneNumber = InputValidator.readPhoneNumber('Phone Number');
      final address = InputValidator.readString('Address');

      final hasMedicalHistory = InputValidator.readConfirmation(
        'Does patient have medical history to record?',
      );

      String? medicalHistory;
      if (hasMedicalHistory) {
        medicalHistory = InputValidator.readString('Medical History');
      }

      final patient = await _patientService.createPatient(
        name: name,
        age: age,
        gender: gender,
        phoneNumber: phoneNumber,
        address: address,
        medicalHistory: medicalHistory,
      );

      ConsoleHelper.printSuccess('Patient registered successfully!');
      ConsoleHelper.printInfo('Patient ID: ${patient.id}');
      ConsoleHelper.printInfo('Name: ${patient.name}');
      ConsoleHelper.printInfo('Phone: ${patient.phoneNumber}');
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewAllPatients() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('All Patients');

    try {
      final patients = await _patientService.getAllPatients();

      if (patients.isEmpty) {
        ConsoleHelper.printInfo('No patients found');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Name', 'Age', 'Gender', 'Phone'],
          [15, 20, 5, 8, 15],
        );

        for (var patient in patients) {
          ConsoleHelper.printTableRow(
            [
              patient.id,
              patient.name,
              '${patient.age}',
              patient.gender.displayName,
              patient.phoneNumber,
            ],
            [15, 20, 5, 8, 15],
          );
        }

        print('\nTotal: ${patients.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _searchPatientByName() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Search Patient by Name');

    try {
      final name = InputValidator.readString('Enter patient name');
      final patients = await _patientService.searchPatientsByName(name);

      if (patients.isEmpty) {
        ConsoleHelper.printInfo('No patients found');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Name', 'Age', 'Phone', 'Address'],
          [15, 20, 5, 15, 25],
        );

        for (var patient in patients) {
          ConsoleHelper.printTableRow(
            [
              patient.id,
              patient.name,
              '${patient.age}',
              patient.phoneNumber,
              patient.address,
            ],
            [15, 20, 5, 15, 25],
          );
        }

        print('\nFound: ${patients.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _updatePatient() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Update Patient');

    try {
      final id = await _selectPatientByName();
      if (id == null) {
        ConsoleHelper.printWarning('Operation cancelled');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final patient = await _patientService.getPatientById(id);

      if (patient == null) {
        ConsoleHelper.printError('Patient not found');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      ConsoleHelper.printInfo(
        'Current: ${patient.name}, ${patient.age}y, ${patient.phoneNumber}',
      );

      final newPhone = InputValidator.readString(
        'New Phone Number (or press Enter to keep current)',
        allowEmpty: true,
      );

      final newAddress = InputValidator.readString(
        'New Address (or press Enter to keep current)',
        allowEmpty: true,
      );

      // Create updated patient (keeping old values if not changed)
      final updatedPatient = await _patientService.getPatientById(id);
      // In real implementation, you'd need to recreate the patient object
      // with new values. For simplicity, showing the concept.

      ConsoleHelper.printInfo(
        'Update feature: Modify patient properties and save',
      );
      ConsoleHelper.printWarning(
        'Full implementation requires recreating patient object',
      );
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _deletePatient() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Delete Patient');

    try {
      final id = await _selectPatientByName();
      if (id == null) {
        ConsoleHelper.printWarning('Operation cancelled');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final patient = await _patientService.getPatientById(id);
      if (patient != null) {
        ConsoleHelper.printInfo(
          'Selected: ${patient.name} (${patient.phoneNumber})',
        );
      }

      if (InputValidator.readConfirmation(
        'Are you sure you want to delete this patient?',
      )) {
        final deleted = await _patientService.deletePatient(id);

        if (deleted) {
          ConsoleHelper.printSuccess('Patient deleted successfully');
        } else {
          ConsoleHelper.printError('Patient not found');
        }
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  // ========== APPOINTMENT MANAGEMENT ==========
  Future<void> _manageAppointments() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Manage Appointments');

      ConsoleHelper.printMenu([
        'Create New Appointment',
        'View All Appointments',
        'View Upcoming Appointments',
        'View Today\'s Appointments',
        'Cancel Appointment',
        'Complete Appointment',
        'Delete Appointment',
        'Back to Main Menu',
      ]);

      final choice = InputValidator.readChoice('\nEnter your choice', 8);

      switch (choice) {
        case 1:
          await _createAppointment();
          break;
        case 2:
          await _viewAllAppointments();
          break;
        case 3:
          await _viewUpcomingAppointments();
          break;
        case 4:
          await _viewTodaysAppointments();
          break;
        case 5:
          await _cancelAppointment();
          break;
        case 6:
          await _completeAppointment();
          break;
        case 7:
          await _deleteAppointment();
          break;
        case 8:
          return;
      }
    }
  }

  Future<void> _createAppointment() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Create New Appointment');

    try {
      // Select patient by name
      print('\n--- Select Patient ---');
      final patientId = await _selectPatientByName();
      if (patientId == null) {
        ConsoleHelper.printWarning('Operation cancelled');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Select doctor by name/specialization
      print('\n--- Select Doctor ---');
      final doctorId = await _selectDoctorByName();
      if (doctorId == null) {
        ConsoleHelper.printWarning('Operation cancelled');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final appointmentDate = InputValidator.readDateTime(
        'Appointment Date & Time',
      );
      final reason = InputValidator.readString('Reason for Visit');

      final appointment = await _appointmentService.createAppointment(
        patientId: patientId,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        reason: reason,
      );

      ConsoleHelper.printSuccess('Appointment created successfully!');
      ConsoleHelper.printInfo('Appointment ID: ${appointment.id}');
      ConsoleHelper.printInfo(
        'Date: ${ConsoleHelper.formatDateTime(appointment.appointmentDate)}',
      );
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewAllAppointments() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('All Appointments');

    try {
      final appointments = await _appointmentService.getAllAppointments();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No appointments found');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Patient ID', 'Doctor ID', 'Date', 'Status'],
          [15, 15, 15, 18, 12],
        );

        for (var apt in appointments) {
          ConsoleHelper.printTableRow(
            [
              apt.id,
              apt.patientId,
              apt.doctorId,
              ConsoleHelper.formatDateTime(apt.appointmentDate),
              apt.status.displayName,
            ],
            [15, 15, 15, 18, 12],
          );
        }

        print('\nTotal: ${appointments.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewUpcomingAppointments() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Upcoming Appointments');

    try {
      final appointments = await _appointmentService.getUpcomingAppointments();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No upcoming appointments');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Patient', 'Doctor', 'Date & Time', 'Reason'],
          [15, 15, 15, 18, 25],
        );

        for (var apt in appointments) {
          ConsoleHelper.printTableRow(
            [
              apt.id,
              apt.patientId,
              apt.doctorId,
              ConsoleHelper.formatDateTime(apt.appointmentDate),
              apt.reason,
            ],
            [15, 15, 15, 18, 25],
          );
        }

        print('\nUpcoming: ${appointments.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewTodaysAppointments() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Today\'s Appointments');

    try {
      final appointments = await _appointmentService.getTodaysAppointments();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No appointments today');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Patient', 'Doctor', 'Time', 'Status'],
          [15, 15, 15, 10, 12],
        );

        for (var apt in appointments) {
          final time =
              '${apt.appointmentDate.hour.toString().padLeft(2, '0')}:'
              '${apt.appointmentDate.minute.toString().padLeft(2, '0')}';
          ConsoleHelper.printTableRow(
            [apt.id, apt.patientId, apt.doctorId, time, apt.status.displayName],
            [15, 15, 15, 10, 12],
          );
        }

        print('\nToday: ${appointments.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _cancelAppointment() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Cancel Appointment');

    try {
      await _viewUpcomingAppointments();

      final id = InputValidator.readString('Enter Appointment ID to cancel');

      if (InputValidator.readConfirmation('Are you sure?')) {
        await _appointmentService.cancelAppointment(id);
        ConsoleHelper.printSuccess('Appointment cancelled successfully');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _completeAppointment() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Complete Appointment');

    try {
      final id = InputValidator.readString('Enter Appointment ID to complete');

      final addNotes = InputValidator.readConfirmation('Add completion notes?');
      String? notes;
      if (addNotes) {
        notes = InputValidator.readString('Completion Notes');
      }

      await _appointmentService.completeAppointment(id, notes: notes);
      ConsoleHelper.printSuccess('Appointment marked as completed');
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _deleteAppointment() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Delete Appointment');

    try {
      await _viewAllAppointments();

      final id = InputValidator.readString('Enter Appointment ID to delete');

      if (InputValidator.readConfirmation('Are you sure?')) {
        final deleted = await _appointmentService.deleteAppointment(id);

        if (deleted) {
          ConsoleHelper.printSuccess('Appointment deleted successfully');
        } else {
          ConsoleHelper.printError('Appointment not found');
        }
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }
}

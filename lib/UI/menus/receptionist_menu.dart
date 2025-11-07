import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../Domain/models/user.dart';
import '../../Domain/models/doctor.dart';
import '../../Domain/models/patient.dart';
import '../../Domain/models/room.dart';
import '../../Domain/enums/gender.dart';
import '../../Domain/enums/shift.dart';
import '../../Domain/enums/appointment_status.dart';
import '../../Service/patient_service.dart';
import '../../Service/appointment_service.dart';
import '../../Service/user_service.dart';
import '../../Service/room_service.dart';
import '../utils/console_utils.dart';

class ReceptionistMenu {
  final User _currentUser;
  final PatientService _patientService;
  final AppointmentService _appointmentService;
  final UserService _userService;
  final RoomService _roomService;
  final uuid = const Uuid();

  ReceptionistMenu(
    this._currentUser,
    this._patientService,
    this._appointmentService,
    this._userService,
    this._roomService,
  );

  void display() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n${'=' * 50}');
      print('RECEPTIONIST MENU - ${_currentUser.name}');
      print('=' * 50);
      print('1. Manage Patients');
      print('2. Manage Appointments');
      print('3. Logout');
      print('=' * 50);
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _managePatients();
          break;
        case '2':
          _manageAppointments();
          break;
        case '3':
          print('\nLogging out...');
          sleep(Duration(seconds: 1));
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _managePatients() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n--- MANAGE PATIENTS ---');
      print('1. Add Patient');
      print('2. View All Patients');
      print('3. Search Patient');
      print('4. Update Patient');
      print('5. Delete Patient');
      print('6. Back');
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          _addPatient();
          break;
        case '2':
          _viewAllPatients();
          break;
        case '3':
          _searchPatient();
          break;
        case '4':
          _updatePatient();
          break;
        case '5':
          _deletePatient();
          break;
        case '6':
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _addPatient() {
    print('\n--- ADD PATIENT ---');

    // Auto-generate Patient ID
    final id = 'PAT-${uuid.v4().substring(0, 8).toUpperCase()}';
    print('Generated Patient ID: $id');

    stdout.write('Enter Name: ');
    final name = stdin.readLineSync() ?? '';
    print('Select Gender: 1. Male  2. Female  3. Other');
    stdout.write('Choice: ');
    final genderChoice = stdin.readLineSync();
    final gender = genderChoice == '1'
        ? Gender.male
        : genderChoice == '2'
        ? Gender.female
        : Gender.other;
    stdout.write('Enter Age: ');
    final ageStr = stdin.readLineSync() ?? '';
    final age = int.tryParse(ageStr) ?? 0;

    if (age <= 0 || age > 150) {
      print('Invalid age!');
      return;
    }

    stdout.write('Enter Phone (10 digits): ');
    final phoneNumber = stdin.readLineSync() ?? '';
    stdout.write('Enter Address: ');
    final address = stdin.readLineSync() ?? '';
    stdout.write('Enter Medical History (optional): ');
    final medicalHistory = stdin.readLineSync();

    final success = _patientService.addPatient(
      id: id,
      name: name,
      gender: gender,
      age: age,
      phoneNumber: phoneNumber,
      address: address,
      medicalHistory: medicalHistory?.isEmpty ?? true ? null : medicalHistory,
    );

    print(
      success
          ? '\n✓ Patient added successfully!'
          : '\n✗ Failed to add patient.',
    );
  }

  void _viewAllPatients() {
    final patients = _patientService.getAllPatients();
    if (patients.isEmpty) {
      print('\nNo patients found.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }
    print('\n--- ALL PATIENTS ---');
    for (var patient in patients) {
      print('\n${'-' * 40}');
      patient.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _searchPatient() {
    stdout.write('\nEnter Patient Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for patient by name
    final patients = _patientService.getAllPatients();
    final matchingPatients = patients
        .where((p) => p.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingPatients.isEmpty) {
      print('No patient found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    if (matchingPatients.length == 1) {
      print('\n--- PATIENT INFORMATION ---');
      matchingPatients.first.displayInfo();
    } else {
      print('\nMultiple patients found:');
      for (int i = 0; i < matchingPatients.length; i++) {
        print(
          '${i + 1}. ${matchingPatients[i].name} (${matchingPatients[i].id})',
        );
      }
      print('0. Cancel');
      stdout.write(
        '\nSelect patient (1-${matchingPatients.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null || choice < 0 || choice > matchingPatients.length) {
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

      print('\n--- PATIENT INFORMATION ---');
      matchingPatients[choice - 1].displayInfo();
    }
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _updatePatient() {
    stdout.write('\nEnter Patient Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for patient by name
    final patients = _patientService.getAllPatients();
    final matchingPatients = patients
        .where((p) => p.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingPatients.isEmpty) {
      print('No patient found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Patient? selectedPatient;
    if (matchingPatients.length == 1) {
      selectedPatient = matchingPatients.first;
    } else {
      print('\nMultiple patients found:');
      for (int i = 0; i < matchingPatients.length; i++) {
        print(
          '${i + 1}. ${matchingPatients[i].name} (${matchingPatients[i].id})',
        );
      }
      print('0. Cancel');
      stdout.write(
        '\nSelect patient (1-${matchingPatients.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null || choice < 0 || choice > matchingPatients.length) {
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

      selectedPatient = matchingPatients[choice - 1];
    }

    print('\n--- CURRENT PATIENT INFORMATION ---');
    selectedPatient.displayInfo();

    print('\nWhat would you like to update?');
    print('1. Phone Number');
    print('2. Address');
    print('3. Medical History');
    print('0. Cancel');
    stdout.write('\nEnter choice (1-3, 0 to cancel): ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 0 || choice > 3) {
      print('Invalid choice!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    if (choice == 0) {
      print('Update cancelled.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    switch (choice) {
      case 1:
        stdout.write('Enter new Phone Number: ');
        final newPhone = stdin.readLineSync() ?? '';

        if (!_validatePatientUpdate(
          fieldName: 'phone number',
          newValue: newPhone,
          currentValue: selectedPatient.phoneNumber,
          validationType: 'phone',
        )) {
          return;
        }

        final updatedPatient1 = Patient(
          id: selectedPatient.id,
          name: selectedPatient.name,
          age: selectedPatient.age,
          gender: selectedPatient.gender,
          phoneNumber: newPhone,
          address: selectedPatient.address,
          medicalHistory: selectedPatient.medicalHistory,
          registrationDate: selectedPatient.registrationDate,
        );
        if (_patientService.updatePatient(updatedPatient1)) {
          print('Patient phone number updated successfully!');
        }
        break;

      case 2:
        stdout.write('Enter new Address: ');
        final newAddress = stdin.readLineSync() ?? '';

        if (!_validatePatientUpdate(
          fieldName: 'address',
          newValue: newAddress,
          currentValue: selectedPatient.address,
        )) {
          return;
        }

        final updatedPatient2 = Patient(
          id: selectedPatient.id,
          name: selectedPatient.name,
          age: selectedPatient.age,
          gender: selectedPatient.gender,
          phoneNumber: selectedPatient.phoneNumber,
          address: newAddress,
          medicalHistory: selectedPatient.medicalHistory,
          registrationDate: selectedPatient.registrationDate,
        );
        if (_patientService.updatePatient(updatedPatient2)) {
          print('Patient address updated successfully!');
        }
        break;

      case 3:
        stdout.write('Enter new Medical History: ');
        final newMedicalHistory = stdin.readLineSync() ?? '';

        if (!_validatePatientUpdate(
          fieldName: 'medical history',
          newValue: newMedicalHistory,
          currentValue: selectedPatient.medicalHistory,
        )) {
          return;
        }

        final updatedPatient3 = Patient(
          id: selectedPatient.id,
          name: selectedPatient.name,
          age: selectedPatient.age,
          gender: selectedPatient.gender,
          phoneNumber: selectedPatient.phoneNumber,
          address: selectedPatient.address,
          medicalHistory: newMedicalHistory,
          registrationDate: selectedPatient.registrationDate,
        );
        if (_patientService.updatePatient(updatedPatient3)) {
          print('Patient medical history updated successfully!');
        }
        break;
    }

    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _deletePatient() {
    stdout.write('\nEnter Patient Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for patient by name
    final patients = _patientService.getAllPatients();
    final matchingPatients = patients
        .where((p) => p.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingPatients.isEmpty) {
      print('No patient found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Patient? selectedPatient;
    if (matchingPatients.length == 1) {
      selectedPatient = matchingPatients.first;
    } else {
      print('\nMultiple patients found:');
      for (int i = 0; i < matchingPatients.length; i++) {
        print(
          '${i + 1}. ${matchingPatients[i].name} (${matchingPatients[i].id})',
        );
      }
      print('0. Cancel');
      stdout.write(
        '\nSelect patient (1-${matchingPatients.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null || choice < 0 || choice > matchingPatients.length) {
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

      selectedPatient = matchingPatients[choice - 1];
    }

    print('\n--- PATIENT INFORMATION ---');
    selectedPatient.displayInfo();

    stdout.write('\nAre you sure you want to delete this patient? (yes/no): ');
    final confirmation = stdin.readLineSync()?.toLowerCase();

    if (confirmation == 'yes') {
      if (_patientService.deletePatient(selectedPatient.id)) {
        print('\n✓ Patient deleted successfully!');
      } else {
        print('\n✗ Failed to delete patient!');
      }
    } else {
      print('Deletion cancelled.');
    }

    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _manageAppointments() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n--- MANAGE APPOINTMENTS ---');
      print('1. Create Appointment');
      print('2. View All Appointments');
      print('3. Update Appointment Status');
      print('4. Delete Appointment');
      print('5. Back');
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _createAppointment();
          break;
        case '2':
          _viewAllAppointments();
          break;
        case '3':
          _updateAppointmentStatus();
          break;
        case '4':
          _deleteAppointment();
          break;
        case '5':
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _createAppointment() {
    print('\n--- CREATE APPOINTMENT ---');

    // Generate UUID for appointment ID
    final id = 'APT-${uuid.v4().substring(0, 8).toUpperCase()}';
    print('Generated Appointment ID: $id');

    // Search for patient by name
    stdout.write('\nEnter Patient Name: ');
    final patientName = stdin.readLineSync() ?? '';

    final patients = _patientService.getAllPatients();
    final matchingPatients = patients
        .where((p) => p.name.toLowerCase().contains(patientName.toLowerCase()))
        .toList();

    if (matchingPatients.isEmpty) {
      print('No patient found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Patient? selectedPatient;
    if (matchingPatients.length == 1) {
      selectedPatient = matchingPatients.first;
      print('Selected: ${selectedPatient.name} (${selectedPatient.id})');
    } else {
      print('\nMultiple patients found:');
      for (int i = 0; i < matchingPatients.length; i++) {
        print(
          '${i + 1}. ${matchingPatients[i].name} (${matchingPatients[i].id})',
        );
      }
      print('0. Cancel');
      stdout.write(
        '\nSelect patient (1-${matchingPatients.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null || choice < 0 || choice > matchingPatients.length) {
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

      selectedPatient = matchingPatients[choice - 1];
    }

    // Search for doctor by name
    stdout.write('\nEnter Doctor Name: ');
    final doctorName = stdin.readLineSync() ?? '';

    final doctors = _userService.getAllDoctors();
    final matchingDoctors = doctors
        .where((d) => d.name.toLowerCase().contains(doctorName.toLowerCase()))
        .toList();

    if (matchingDoctors.isEmpty) {
      print('No doctor found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Doctor? selectedDoctor;
    if (matchingDoctors.length == 1) {
      selectedDoctor = matchingDoctors.first;
      print('\nSelected Doctor:');
      print('  Name: ${selectedDoctor.name}');
      print('  Specialization: ${selectedDoctor.specialization}');
      print('  Department: ${selectedDoctor.department}');
      print('  Shift: ${selectedDoctor.shift.displayName}');
      _displayDoctorSchedule(selectedDoctor.id);
    } else {
      print('\nMultiple doctors found:');
      for (int i = 0; i < matchingDoctors.length; i++) {
        print(
          '${i + 1}. ${matchingDoctors[i].name} - ${matchingDoctors[i].specialization} (${matchingDoctors[i].department})',
        );
      }
      print('0. Cancel');
      stdout.write(
        '\nSelect doctor (1-${matchingDoctors.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null || choice < 0 || choice > matchingDoctors.length) {
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

      selectedDoctor = matchingDoctors[choice - 1];
      print('\nSelected Doctor:');
      print('  Name: ${selectedDoctor.name}');
      print('  Specialization: ${selectedDoctor.specialization}');
      print('  Department: ${selectedDoctor.department}');
      print('  Shift: ${selectedDoctor.shift.displayName}');
      _displayDoctorSchedule(selectedDoctor.id);
    }

    // Get appointment date and time
    stdout.write('\nEnter Date & Time (YYYY-MM-DD HH:MM or YYYY-M-D H:MM): ');
    final dateTimeStr = stdin.readLineSync() ?? '';

    DateTime? appointmentDateTime = _parseDateTime(dateTimeStr);
    if (appointmentDateTime == null) {
      print(
        'Invalid date format! Examples: 2025-12-01 10:00 or 2025-12-1 10:00',
      );
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    // Validate appointment time gap with doctor
    if (!_validateAppointmentTimeGap(
      selectedDoctor.id,
      null,
      appointmentDateTime,
    )) {
      return;
    }

    // Search for available rooms
    stdout.write('\nDo you want to assign a room? (yes/no): ');
    final assignRoom = stdin.readLineSync()?.toLowerCase();

    String? selectedRoomId;
    if (assignRoom == 'yes') {
      final availableRooms = _getAvailableRooms(appointmentDateTime);

      if (availableRooms.isEmpty) {
        print('\n⚠ No rooms available at this time!');
        stdout.write('Continue without room assignment? (yes/no): ');
        if (stdin.readLineSync()?.toLowerCase() != 'yes') {
          print('Operation cancelled.');
          stdout.write('\nPress Enter to continue...');
          stdin.readLineSync();
          return;
        }
      } else {
        print('\n--- AVAILABLE ROOMS ---');
        for (int i = 0; i < availableRooms.length; i++) {
          final room = availableRooms[i];
          print(
            '${i + 1}. Room ${room.roomNumber} - ${room.type.name} (${room.bedCount} beds) - ${room.status.name}',
          );
        }
        print('0. Skip room assignment');

        stdout.write('\nSelect room (1-${availableRooms.length}, 0 to skip): ');
        final choice = int.tryParse(stdin.readLineSync() ?? '');

        if (choice == null || choice < 0 || choice > availableRooms.length) {
          print('Invalid selection!');
          stdout.write('\nPress Enter to continue...');
          stdin.readLineSync();
          return;
        }

        if (choice > 0) {
          selectedRoomId = availableRooms[choice - 1].id;
          print('Selected: Room ${availableRooms[choice - 1].roomNumber}');
        }
      }
    }

    stdout.write('\nEnter Reason for Appointment: ');
    final reason = stdin.readLineSync() ?? '';

    if (!_validateAppointmentInput(reason)) {
      return;
    }

    final success = _appointmentService.createAppointment(
      id: id,
      patientId: selectedPatient.id,
      doctorId: selectedDoctor.id,
      roomId: selectedRoomId,
      dateTime: appointmentDateTime,
      reason: reason,
    );

    if (success) {
      print('\n✓ Appointment created successfully!');
      print('  Appointment ID: $id');
      print('  Patient: ${selectedPatient.name}');
      print('  Doctor: ${selectedDoctor.name}');
      print('  Date & Time: $appointmentDateTime');
      if (selectedRoomId != null) {
        final room = _roomService.getAllRooms().firstWhere(
          (r) => r.id == selectedRoomId,
        );
        print('  Room: ${room.roomNumber}');
      }
    } else {
      print('\n✗ Failed to create appointment.');
    }

    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _viewAllAppointments() {
    final appointments = _appointmentService.getAllAppointments();
    if (appointments.isEmpty) {
      print('\nNo appointments found.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }
    print('\n--- ALL APPOINTMENTS ---');
    for (var appointment in appointments) {
      print('\n${'-' * 40}');
      appointment.displayInfo();

      final patient = _patientService.getPatientById(appointment.patientId);
      final doctor = _userService.getDoctorById(appointment.doctorId);

      if (patient != null) print('Patient Name: ${patient.name}');
      if (doctor != null) print('Doctor Name: ${doctor.name}');
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _updateAppointmentStatus() {
    final appointments = _appointmentService.getAllAppointments();

    if (appointments.isEmpty) {
      print('\nNo appointments found!');
      return;
    }

    print('\n=== All Appointments ===');
    for (var i = 0; i < appointments.length; i++) {
      print('\n${i + 1}. Appointment ID: ${appointments[i].id}');
      print('   Patient ID: ${appointments[i].patientId}');
      print('   Doctor ID: ${appointments[i].doctorId}');
      print('   Date & Time: ${appointments[i].dateTime}');
      print('   Status: ${appointments[i].status.name}');
      print('   Reason: ${appointments[i].reason}');
    }

    stdout.write('\nSelect appointment number to update (or 0 to cancel): ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 1 || choice > appointments.length) {
      print('Invalid selection!');
      return;
    }

    final appointment = appointments[choice - 1];

    print('\nCurrent Status: ${appointment.status.name}');
    print('Select New Status:');
    print('1. Scheduled');
    print('2. Completed');
    print('3. Cancelled');
    stdout.write('Choice: ');

    final statusChoice = stdin.readLineSync();

    final newStatus = statusChoice == '1'
        ? AppointmentStatus.scheduled
        : statusChoice == '2'
        ? AppointmentStatus.completed
        : AppointmentStatus.cancelled;

    String? notes;
    if (newStatus == AppointmentStatus.completed) {
      stdout.write('Enter notes (optional): ');
      notes = stdin.readLineSync();
    }

    final success = _appointmentService.updateAppointmentStatus(
      appointment.id,
      newStatus,
      notes,
    );
    print(success ? '\n✓ Status updated!' : '\n✗ Update failed!');
  }

  void _deleteAppointment() {
    final appointments = _appointmentService.getAllAppointments();

    if (appointments.isEmpty) {
      print('\nNo appointments found!');
      return;
    }

    print('\n=== All Appointments ===');
    for (var i = 0; i < appointments.length; i++) {
      print('\n${i + 1}. Appointment ID: ${appointments[i].id}');
      print('   Patient ID: ${appointments[i].patientId}');
      print('   Doctor ID: ${appointments[i].doctorId}');
      print('   Date & Time: ${appointments[i].dateTime}');
      print('   Status: ${appointments[i].status.name}');
      print('   Reason: ${appointments[i].reason}');
    }

    stdout.write('\nSelect appointment number to delete (or 0 to cancel): ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 1 || choice > appointments.length) {
      print('Invalid selection!');
      return;
    }

    final appointment = appointments[choice - 1];

    print('\nAppointment Information:');
    appointment.displayInfo();
    stdout.write('\nConfirm deletion? (yes/no): ');
    if (stdin.readLineSync()?.toLowerCase() == 'yes') {
      print(
        _appointmentService.deleteAppointment(appointment.id)
            ? '\n✓ Deleted!'
            : '\n✗ Failed!',
      );
    } else {
      print('\nDeletion cancelled.');
    }
  }

  // Helper method to parse date time with flexible format
  DateTime? _parseDateTime(String dateTimeStr) {
    try {
      // Try standard format first (YYYY-MM-DD HH:MM)
      return DateTime.parse(dateTimeStr.replaceAll(' ', 'T'));
    } catch (e) {
      try {
        // Try parsing with single digit day/month
        final parts = dateTimeStr.split(' ');
        if (parts.length != 2) return null;

        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        if (dateParts.length != 3 || timeParts.length != 2) return null;

        final year = int.tryParse(dateParts[0]);
        final month = int.tryParse(dateParts[1]);
        final day = int.tryParse(dateParts[2]);
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);

        if (year == null ||
            month == null ||
            day == null ||
            hour == null ||
            minute == null) {
          return null;
        }

        return DateTime(year, month, day, hour, minute);
      } catch (e) {
        return null;
      }
    }
  }

  // Helper method to display doctor's upcoming schedule
  void _displayDoctorSchedule(String doctorId) {
    final appointments = _appointmentService.getUpcomingAppointments(doctorId);

    if (appointments.isEmpty) {
      print('  Schedule: No upcoming appointments');
    } else {
      print('  Upcoming Appointments:');
      final now = DateTime.now();
      final upcomingToday = appointments
          .where(
            (a) =>
                a.dateTime.year == now.year &&
                a.dateTime.month == now.month &&
                a.dateTime.day == now.day,
          )
          .take(3)
          .toList();

      if (upcomingToday.isEmpty) {
        print('    No appointments today');
      } else {
        for (var apt in upcomingToday) {
          print(
            '    - ${apt.dateTime.hour.toString().padLeft(2, '0')}:${apt.dateTime.minute.toString().padLeft(2, '0')}',
          );
        }
      }
    }
  }

  // Helper method to get available rooms at a specific time
  List<Room> _getAvailableRooms(DateTime appointmentTime) {
    final allRooms = _roomService.getAllRooms();
    final allAppointments = _appointmentService.getAllAppointments();

    // Filter rooms that are available (not in use within 1 hour of appointment time)
    return allRooms.where((room) {
      // Check if room has any appointments within 1 hour of the requested time
      final roomAppointments = allAppointments
          .where(
            (a) =>
                a.roomId == room.id && a.status == AppointmentStatus.scheduled,
          )
          .toList();

      for (var appointment in roomAppointments) {
        final timeDifference = appointment.dateTime
            .difference(appointmentTime)
            .abs();
        if (timeDifference.inMinutes < 60) {
          return false; // Room is not available
        }
      }

      return room.status.name == 'available'; // Room is available
    }).toList();
  }

  // Validation helper function for appointment input
  bool _validateAppointmentInput(String reason) {
    if (reason.trim().isEmpty) {
      print('Reason for appointment cannot be empty!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return false;
    }
    return true;
  }

  // Validation helper function for appointment time gap (1 hour)
  bool _validateAppointmentTimeGap(
    String doctorId,
    String? roomId,
    DateTime appointmentDateTime,
  ) {
    final allAppointments = _appointmentService.getAllAppointments();

    // Check for conflicts with same doctor
    final doctorAppointments = allAppointments
        .where(
          (a) =>
              a.doctorId == doctorId && a.status == AppointmentStatus.scheduled,
        )
        .toList();

    for (var appointment in doctorAppointments) {
      final timeDifference = appointment.dateTime
          .difference(appointmentDateTime)
          .abs();
      if (timeDifference.inMinutes < 60) {
        print(
          '\n⚠ Doctor already has an appointment within 1 hour of this time!',
        );
        print('Existing appointment: ${appointment.dateTime}');
        print('Please choose a different time slot.');
        stdout.write('\nPress Enter to continue...');
        stdin.readLineSync();
        return false;
      }
    }

    // Check for conflicts with same room (if room is assigned)
    if (roomId != null) {
      final roomAppointments = allAppointments
          .where(
            (a) =>
                a.roomId == roomId && a.status == AppointmentStatus.scheduled,
          )
          .toList();

      for (var appointment in roomAppointments) {
        final timeDifference = appointment.dateTime
            .difference(appointmentDateTime)
            .abs();
        if (timeDifference.inMinutes < 60) {
          print(
            '\n⚠ Room already has an appointment within 1 hour of this time!',
          );
          print('Existing appointment: ${appointment.dateTime}');
          print('Please choose a different time slot or different room.');
          stdout.write('\nPress Enter to continue...');
          stdin.readLineSync();
          return false;
        }
      }
    }

    return true;
  }

  // Validation helper function for patient updates
  bool _validatePatientUpdate({
    required String fieldName,
    required String newValue,
    required String? currentValue,
    String? validationType,
  }) {
    // Check if empty (for non-phone fields)
    if (validationType != 'phone' && newValue.isEmpty) {
      print('$fieldName cannot be empty!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return false;
    }

    // Validate phone number format
    if (validationType == 'phone') {
      if (!RegExp(r'^\d{10}$').hasMatch(newValue)) {
        print('Invalid phone number format! Must be 10 digits.');
        stdout.write('\nPress Enter to continue...');
        stdin.readLineSync();
        return false;
      }
    }

    // Check if value is the same as current
    if (newValue == currentValue) {
      print('New $fieldName is the same as current $fieldName!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return false;
    }

    return true;
  }
}

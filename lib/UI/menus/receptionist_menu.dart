import '../../Domain/services/auth_service.dart';
import '../../Domain/services/patient_service.dart';
import '../../Domain/services/appointment_service.dart';
import '../../Domain/services/doctor_service.dart';
import '../../Domain/services/room_service.dart';
import '../../Domain/models/appointment.dart';
import '../../Domain/models/patient.dart';
import '../../Domain/enums/gender.dart';
import '../../Domain/enums/room_type.dart';
import '../../Domain/enums/appointment_status.dart';
import '../utils/console_helper.dart';
import '../utils/input_valid_utils.dart';

class ReceptionistMenu {
  final AuthService _authService;
  final PatientService _patientService;
  final AppointmentService _appointmentService;
  final DoctorService _doctorService;
  final RoomService _roomService;

  ReceptionistMenu(
    this._authService,
    this._patientService,
    this._appointmentService,
    this._doctorService,
    this._roomService,
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
    print('0. Cancel');
    for (int i = 0; i < patients.length; i++) {
      print(
        '${i + 1}. ${patients[i].name} (Age: ${patients[i].age}, Phone: ${patients[i].phoneNumber})',
      );
    }

    final choice = InputValidator.readChoice('Select patient', patients.length);
    if (choice == 0) return null;

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
    print('0. Cancel');
    for (int i = 0; i < doctors.length; i++) {
      print(
        '${i + 1}. Dr. ${doctors[i].name} - ${doctors[i].specialization} (${doctors[i].yearsOfExperience} years exp.)',
      );
    }

    final choice = InputValidator.readChoice('Select doctor', doctors.length);
    if (choice == 0) return null;

    return doctors[choice - 1].id;
  }

  // Helper: Select room by type
  Future<String?> _selectRoomByType() async {
    // First, let user select room type
    print('\n--- Select Room Type ---');
    final roomTypes = RoomType.values;

    print('0. Cancel');
    for (int i = 0; i < roomTypes.length; i++) {
      print('${i + 1}. ${roomTypes[i].displayName}');
    }

    final typeChoice = InputValidator.readChoice(
      'Select room type',
      roomTypes.length,
    );
    if (typeChoice == 0) return null;

    final selectedType = roomTypes[typeChoice - 1];

    // Get available rooms for that type
    final allRoomsOfType = await _roomService.getRoomsByType(selectedType);

    // Filter to only show available rooms (not occupied or in maintenance)
    final rooms = allRoomsOfType.where((r) => r.isAvailable()).toList();

    if (rooms.isEmpty) {
      ConsoleHelper.printError(
        'No available rooms for ${selectedType.displayName}',
      );
      return null;
    }

    // Display available rooms
    print('\n--- Available ${selectedType.displayName} Rooms ---');
    print('0. Cancel');
    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      print(
        '${i + 1}. Room ${room.roomNumber} - ${room.bedCount} bed(s) - \$${room.pricePerDay}/day',
      );
    }

    final roomChoice = InputValidator.readChoice('Select room', rooms.length);
    if (roomChoice == 0) return null;

    return rooms[roomChoice - 1].id;
  }

  // Helper: Select appointment from a list
  Future<String?> _selectAppointmentFromList(
    List<dynamic> appointments,
    String title,
  ) async {
    if (appointments.isEmpty) {
      ConsoleHelper.printError('No appointments available');
      return null;
    }

    print('\n$title:');
    print('0. Cancel');
    for (int i = 0; i < appointments.length; i++) {
      final apt = appointments[i];
      // Get patient and doctor names
      final patient = await _patientService.getPatientById(apt.patientId);
      final doctor = await _doctorService.getDoctorById(apt.doctorId);
      final room = await _roomService.getRoomById(apt.roomId);

      final patientName = patient?.name ?? 'Unknown';
      final doctorName = doctor?.name ?? 'Unknown';
      final roomNumber = room?.roomNumber ?? 'N/A';
      final dateStr = ConsoleHelper.formatDateTime(apt.appointmentDate);

      print(
        '${i + 1}. $patientName with Dr. $doctorName in Room $roomNumber on $dateStr - ${apt.status.displayName}',
      );
    }

    final choice = InputValidator.readChoice(
      'Select appointment',
      appointments.length,
    );
    if (choice == 0) return null;

    return appointments[choice - 1].id;
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

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        3,
        allowZero: false,
      );

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

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        6,
        allowZero: false,
      );

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
          [
            'ID',
            'Name',
            'Age',
            'Gender',
            'Phone',
            'Address',
            'Medical History',
          ],
          [20, 25, 5, 8, 15, 30, 30],
        );

        for (var patient in patients) {
          ConsoleHelper.printTableRow(
            [
              patient.id,
              patient.name,
              '${patient.age}',
              patient.gender.displayName,
              patient.phoneNumber,
              patient.address,
              patient.medicalHistory ?? 'None',
            ],
            [20, 25, 5, 8, 15, 30, 30],
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
          [20, 25, 5, 15, 30],
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
            [20, 25, 5, 15, 30],
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
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final patient = await _patientService.getPatientById(id);

      if (patient == null) {
        ConsoleHelper.printError('Patient not found');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Display current patient information
      print('\n══════════════════════════════════════');
      print('  CURRENT PATIENT INFORMATION');
      print('══════════════════════════════════════');
      print('Name: ${patient.name}');
      print('Age: ${patient.age}');
      print('Gender: ${patient.gender.displayName}');
      print('Phone: ${patient.phoneNumber}');
      print('Address: ${patient.address}');
      print('Medical History: ${patient.medicalHistory ?? 'None'}');
      print('══════════════════════════════════════\n');

      // Get new values (allow keeping current values)
      final newName = InputValidator.readString(
        'New Name (or press Enter to keep "${patient.name}")',
        allowEmpty: true,
      );

      final ageInput = InputValidator.readString(
        'New Age (or press Enter to keep ${patient.age})',
        allowEmpty: true,
      );
      final newAge = ageInput.isEmpty ? patient.age : int.parse(ageInput);

      // Gender update
      final updateGender = InputValidator.readConfirmation(
        'Update Gender? Current: ${patient.gender.displayName}',
      );
      Gender newGender = patient.gender;
      if (updateGender) {
        print('\nSelect new gender:');
        ConsoleHelper.printMenu(['Male', 'Female', 'Other']);
        final genderChoice = InputValidator.readChoice('Select gender', 3);
        newGender = Gender.values[genderChoice - 1];
      }

      final newPhone = InputValidator.readString(
        'New Phone Number (or press Enter to keep "${patient.phoneNumber}")',
        allowEmpty: true,
      );

      final newAddress = InputValidator.readString(
        'New Address (or press Enter to keep current)',
        allowEmpty: true,
      );

      // Medical history update
      final updateMedHistory = InputValidator.readConfirmation(
        'Update Medical History? Current: ${patient.medicalHistory ?? 'None'}',
      );
      String? newMedicalHistory = patient.medicalHistory;
      if (updateMedHistory) {
        newMedicalHistory = InputValidator.readString(
          'New Medical History (or press Enter to clear)',
          allowEmpty: true,
        );
        if (newMedicalHistory.isEmpty) {
          newMedicalHistory = null;
        }
      }

      // Create updated patient object
      final updatedPatient = Patient(
        id: patient.id,
        name: newName.isEmpty ? patient.name : newName,
        age: newAge,
        gender: newGender,
        phoneNumber: newPhone.isEmpty ? patient.phoneNumber : newPhone,
        address: newAddress.isEmpty ? patient.address : newAddress,
        medicalHistory: newMedicalHistory,
        registrationDate: patient.registrationDate,
      );

      // Confirm update
      if (InputValidator.readConfirmation('Confirm update?')) {
        await _patientService.updatePatient(updatedPatient);

        ConsoleHelper.printSuccess('Patient updated successfully!');

        // Display updated information
        print('\n══════════════════════════════════════');
        print('  UPDATED PATIENT INFORMATION');
        print('══════════════════════════════════════');
        print('Name: ${updatedPatient.name}');
        print('Age: ${updatedPatient.age}');
        print('Gender: ${updatedPatient.gender.displayName}');
        print('Phone: ${updatedPatient.phoneNumber}');
        print('Address: ${updatedPatient.address}');
        print('Medical History: ${updatedPatient.medicalHistory ?? 'None'}');
        print('══════════════════════════════════════');
      } else {
        ConsoleHelper.printInfo('Update cancelled');
      }
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
        'Search Appointment by Patient Name',
        'Search Appointment by Date',
        'Update Appointment',
        'Cancel Appointment',
        'Complete Appointment',
        'Delete Appointment',
        'Back to Main Menu',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        10,
        allowZero: false,
      );

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
          await _searchAppointmentByPatientName();
          break;
        case 5:
          await _searchAppointmentByDate();
          break;
        case 6:
          await _updateAppointment();
          break;
        case 7:
          await _cancelAppointment();
          break;
        case 8:
          await _completeAppointment();
          break;
        case 9:
          await _deleteAppointment();
          break;
        case 10:
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
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Select doctor by name/specialization
      print('\n--- Select Doctor ---');
      final doctorId = await _selectDoctorByName();
      if (doctorId == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final appointmentDate = InputValidator.readDateTime(
        'Appointment Date & Time',
      );

      // Select room by type
      print('\n--- Select Room for Appointment ---');
      final roomId = await _selectRoomByType();
      if (roomId == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final reason = InputValidator.readString('Reason for Visit');

      final appointment = await _appointmentService.createAppointment(
        patientId: patientId,
        doctorId: doctorId,
        roomId: roomId,
        appointmentDate: appointmentDate,
        reason: reason,
      );

      ConsoleHelper.printSuccess('Appointment created successfully!');
      ConsoleHelper.printInfo('Appointment ID: ${appointment.id}');
      ConsoleHelper.printInfo(
        'Date: ${ConsoleHelper.formatDateTime(appointment.appointmentDate)}',
      );

      // Show room information
      final room = await _roomService.getRoomById(roomId);
      if (room != null) {
        ConsoleHelper.printInfo(
          'Room: ${room.roomNumber} (${room.type.displayName})',
        );
      }
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
          ['ID', 'Patient Name', 'Doctor Name', 'Room', 'Date', 'Status'],
          [20, 25, 25, 10, 18, 12],
        );

        for (var apt in appointments) {
          // Get patient and doctor names
          final patient = await _patientService.getPatientById(apt.patientId);
          final doctor = await _doctorService.getDoctorById(apt.doctorId);
          final room = await _roomService.getRoomById(apt.roomId);

          final patientName = patient?.name ?? 'Unknown';
          final doctorName = doctor != null ? 'Dr. ${doctor.name}' : 'Unknown';
          final roomNumber = room?.roomNumber ?? 'N/A';

          ConsoleHelper.printTableRow(
            [
              apt.id,
              patientName,
              doctorName,
              roomNumber,
              ConsoleHelper.formatDateTime(apt.appointmentDate),
              apt.status.displayName,
            ],
            [20, 25, 25, 10, 18, 12],
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
          ['ID', 'Patient', 'Doctor', 'Room', 'Date & Time', 'Reason'],
          [20, 20, 20, 10, 18, 30],
        );

        for (var apt in appointments) {
          // Get patient and doctor names
          final patient = await _patientService.getPatientById(apt.patientId);
          final doctor = await _doctorService.getDoctorById(apt.doctorId);
          final room = await _roomService.getRoomById(apt.roomId);

          final patientName = patient?.name ?? 'Unknown';
          final doctorName = doctor != null ? 'Dr. ${doctor.name}' : 'Unknown';
          final roomNumber = room?.roomNumber ?? 'N/A';

          ConsoleHelper.printTableRow(
            [
              apt.id,
              patientName,
              doctorName,
              roomNumber,
              ConsoleHelper.formatDateTime(apt.appointmentDate),
              apt.reason,
            ],
            [20, 20, 20, 10, 18, 30],
          );
        }

        print('\nUpcoming: ${appointments.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _searchAppointmentByPatientName() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Search Appointment by Patient Name');

    try {
      final name = InputValidator.readString('Enter patient name to search');
      final patients = await _patientService.searchPatientsByName(name);

      if (patients.isEmpty) {
        ConsoleHelper.printError('No patients found with that name');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Get all appointments for found patients
      List<dynamic> foundAppointments = [];
      for (var patient in patients) {
        final appointments = await _appointmentService.getAppointmentsByPatient(
          patient.id,
        );
        foundAppointments.addAll(appointments);
      }

      if (foundAppointments.isEmpty) {
        ConsoleHelper.printInfo(
          'No appointments found for patients with that name',
        );
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Patient', 'Doctor', 'Room', 'Date', 'Status'],
          [20, 20, 20, 10, 18, 12],
        );

        for (var apt in foundAppointments) {
          final patient = await _patientService.getPatientById(apt.patientId);
          final doctor = await _doctorService.getDoctorById(apt.doctorId);
          final room = await _roomService.getRoomById(apt.roomId);

          final patientName = patient?.name ?? 'Unknown';
          final doctorName = doctor != null ? 'Dr. ${doctor.name}' : 'Unknown';
          final roomNumber = room?.roomNumber ?? 'N/A';

          ConsoleHelper.printTableRow(
            [
              apt.id,
              patientName,
              doctorName,
              roomNumber,
              ConsoleHelper.formatDateTime(apt.appointmentDate),
              apt.status.displayName,
            ],
            [20, 20, 20, 10, 18, 12],
          );
        }

        print('\nFound: ${foundAppointments.length} appointment(s)');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _searchAppointmentByDate() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Search Appointment by Date');

    try {
      final dateStr = InputValidator.readString(
        'Enter date (YYYY-MM-DD) or just day (DD)',
      );

      DateTime searchDate;

      // Check if user entered just a day number
      if (dateStr.length <= 2 && int.tryParse(dateStr) != null) {
        final now = DateTime.now();
        final day = int.parse(dateStr);
        searchDate = DateTime(now.year, now.month, day);
      } else {
        // Try to parse full date
        try {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            searchDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          } else {
            ConsoleHelper.printError(
              'Invalid date format. Use YYYY-MM-DD or DD',
            );
            ConsoleHelper.pressEnterToContinue();
            return;
          }
        } catch (e) {
          ConsoleHelper.printError('Invalid date format');
          ConsoleHelper.pressEnterToContinue();
          return;
        }
      }

      final allAppointments = await _appointmentService.getAllAppointments();
      final foundAppointments = allAppointments.where((apt) {
        final aptDate = apt.appointmentDate;
        return aptDate.year == searchDate.year &&
            aptDate.month == searchDate.month &&
            aptDate.day == searchDate.day;
      }).toList();

      if (foundAppointments.isEmpty) {
        ConsoleHelper.printInfo(
          'No appointments found for ${searchDate.day}/${searchDate.month}/${searchDate.year}',
        );
      } else {
        print(
          '\nAppointments for ${searchDate.day}/${searchDate.month}/${searchDate.year}:\n',
        );

        ConsoleHelper.printTableHeader(
          ['ID', 'Patient', 'Doctor', 'Room', 'Time', 'Status'],
          [20, 20, 20, 10, 10, 12],
        );

        for (var apt in foundAppointments) {
          final patient = await _patientService.getPatientById(apt.patientId);
          final doctor = await _doctorService.getDoctorById(apt.doctorId);
          final room = await _roomService.getRoomById(apt.roomId);

          final patientName = patient?.name ?? 'Unknown';
          final doctorName = doctor != null ? 'Dr. ${doctor.name}' : 'Unknown';
          final roomNumber = room?.roomNumber ?? 'N/A';

          final time =
              '${apt.appointmentDate.hour.toString().padLeft(2, '0')}:'
              '${apt.appointmentDate.minute.toString().padLeft(2, '0')}';

          ConsoleHelper.printTableRow(
            [
              apt.id,
              patientName,
              doctorName,
              roomNumber,
              time,
              apt.status.displayName,
            ],
            [20, 20, 20, 10, 10, 12],
          );
        }

        print('\nFound: ${foundAppointments.length} appointment(s)');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _updateAppointment() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Update Appointment');

    try {
      // Get ALL appointments and filter by scheduled status
      final allAppointments = await _appointmentService.getAllAppointments();
      final appointments = allAppointments
          .where((apt) => apt.status == AppointmentStatus.scheduled)
          .toList();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No scheduled appointments to update');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final id = await _selectAppointmentFromList(
        appointments,
        'Select appointment to update',
      );

      if (id == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final appointment = await _appointmentService.getAppointmentById(id);
      if (appointment == null) {
        ConsoleHelper.printError('Appointment not found');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Show current appointment details
      final patient = await _patientService.getPatientById(
        appointment.patientId,
      );
      final doctor = await _doctorService.getDoctorById(appointment.doctorId);
      final room = await _roomService.getRoomById(appointment.roomId);

      print('\n══════════════════════════════════════');
      print('  CURRENT APPOINTMENT DETAILS');
      print('══════════════════════════════════════');
      print('Patient: ${patient?.name ?? 'Unknown'}');
      print('Doctor: ${doctor != null ? 'Dr. ${doctor.name}' : 'Unknown'}');
      print('Room: ${room?.roomNumber ?? 'N/A'}');
      print(
        'Date & Time: ${ConsoleHelper.formatDateTime(appointment.appointmentDate)}',
      );
      print('Reason: ${appointment.reason}');
      print('══════════════════════════════════════\n');

      // Ask what to update
      print('What would you like to update?');
      ConsoleHelper.printMenu([
        'Update Date & Time',
        'Update Room',
        'Update Reason',
        'Update All',
        'Cancel',
      ]);

      final updateChoice = InputValidator.readChoice('Select option', 5);
      if (updateChoice == 5 || updateChoice == 0) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      DateTime newDate = appointment.appointmentDate;
      String newRoomId = appointment.roomId;
      String newReason = appointment.reason;

      switch (updateChoice) {
        case 1: // Update Date & Time
          newDate = InputValidator.readDateTime('New Appointment Date & Time');
          break;

        case 2: // Update Room
          print('\n--- Select New Room ---');
          final selectedRoomId = await _selectRoomByType();
          if (selectedRoomId == null) {
            ConsoleHelper.pressEnterToContinue();
            return;
          }
          newRoomId = selectedRoomId;
          break;

        case 3: // Update Reason
          newReason = InputValidator.readString('New Reason for Visit');
          break;

        case 4: // Update All
          newDate = InputValidator.readDateTime('New Appointment Date & Time');
          print('\n--- Select New Room ---');
          final selectedRoomId = await _selectRoomByType();
          if (selectedRoomId == null) {
            ConsoleHelper.pressEnterToContinue();
            return;
          }
          newRoomId = selectedRoomId;
          newReason = InputValidator.readString('New Reason for Visit');
          break;
      }

      if (InputValidator.readConfirmation('Confirm update?')) {
        // Create updated appointment using reschedule or recreate
        final updatedAppointment = Appointment(
          id: appointment.id,
          patientId: appointment.patientId,
          doctorId: appointment.doctorId,
          roomId: newRoomId,
          appointmentDate: newDate,
          status: appointment.status,
          reason: newReason,
          notes: appointment.notes,
          createdAt: appointment.createdAt,
        );

        await _appointmentService.updateAppointment(updatedAppointment);
        ConsoleHelper.printSuccess('Appointment updated successfully!');

        // Show updated details
        final updatedRoom = await _roomService.getRoomById(newRoomId);
        print('\n══════════════════════════════════════');
        print('  UPDATED APPOINTMENT');
        print('══════════════════════════════════════');
        print('Date & Time: ${ConsoleHelper.formatDateTime(newDate)}');
        print('Room: ${updatedRoom?.roomNumber ?? 'N/A'}');
        print('Reason: $newReason');
        print('══════════════════════════════════════');
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
      final appointments = await _appointmentService.getUpcomingAppointments();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No upcoming appointments to cancel');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final id = await _selectAppointmentFromList(
        appointments,
        'Select appointment to cancel',
      );

      if (id == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

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
      // Get ALL appointments and filter by scheduled status
      final allAppointments = await _appointmentService.getAllAppointments();
      final appointments = allAppointments
          .where((apt) => apt.status == AppointmentStatus.scheduled)
          .toList();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No scheduled appointments to complete');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final id = await _selectAppointmentFromList(
        appointments,
        'Select appointment to complete',
      );

      if (id == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

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
      final appointments = await _appointmentService.getAllAppointments();

      if (appointments.isEmpty) {
        ConsoleHelper.printInfo('No appointments to delete');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      final id = await _selectAppointmentFromList(
        appointments,
        'Select appointment to delete',
      );

      if (id == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

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

import '../../Service/auth_service.dart';
import '../../Service/user_service.dart';
import '../../Service/doctor_service.dart';
import '../../Service/room_service.dart';
import '../../Service/patient_service.dart';
import '../../Service/appointment_service.dart';
import '../../Domain/enums/gender.dart';
import '../../Domain/enums/shift.dart';
import '../../Domain/enums/room_type.dart';
import '../utils/console_helper.dart';
import '../utils/input_valid_utils.dart';

class AdminMenu {
  final AuthService _authService;
  final UserService _userService;
  final DoctorService _doctorService;
  final RoomService _roomService;
  final PatientService _patientService;
  final AppointmentService _appointmentService;

  AdminMenu(
    this._authService,
    this._userService,
    this._doctorService,
    this._roomService,
    this._patientService,
    this._appointmentService,
  );

  // ========== HELPER FUNCTIONS ==========

  // Helper: Select receptionist by name
  Future<String?> _selectReceptionistByName() async {
    final receptionists = await _userService.getAllReceptionists();

    if (receptionists.isEmpty) {
      ConsoleHelper.printError('No receptionists found');
      return null;
    }

    print('\nReceptionists:\n');
    for (int i = 0; i < receptionists.length; i++) {
      print(
        '${i + 1}. ${receptionists[i].fullName} (${receptionists[i].username})',
      );
    }

    final choice = InputValidator.readChoiceOrCancel(
      'Select receptionist',
      receptionists.length,
    );
    if (choice == null) return null;

    return receptionists[choice - 1].id;
  }

  // Helper: Select doctor by name
  Future<String?> _selectDoctorByName() async {
    final name = InputValidator.readString(
      'Enter doctor name to search (or specialization)',
    );

    var doctors = await _doctorService.searchBySpecialization(name);

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
      ConsoleHelper.printSuccess('Found: Dr. ${doctors[0].name}');
      return doctors[0].id;
    }

    print('\nDoctors found:\n');
    for (int i = 0; i < doctors.length; i++) {
      print('${i + 1}. Dr. ${doctors[i].name} - ${doctors[i].specialization}');
    }

    final choice = InputValidator.readChoiceOrCancel(
      'Select doctor',
      doctors.length,
    );
    if (choice == null) return null;

    return doctors[choice - 1].id;
  }

  Future<void> show() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Admin Dashboard');

      final user = _authService.currentUser;
      print('Logged in as: ${user?.username} (Admin)\n');

      ConsoleHelper.printMenu([
        'Manage Receptionists',
        'Manage Doctors',
        'Manage Rooms',
        'View Statistics',
        'Logout',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        5,
        allowZero: false,
      );

      switch (choice) {
        case 1:
          await _manageReceptionists();
          break;
        case 2:
          await _manageDoctors();
          break;
        case 3:
          await _manageRooms();
          break;
        case 4:
          await _viewStatistics();
          break;
        case 5:
          return; // Logout
      }
    }
  }

  // ========== RECEPTIONIST MANAGEMENT ==========
  Future<void> _manageReceptionists() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Manage Receptionists');

      ConsoleHelper.printMenu([
        'Create New Receptionist',
        'View All Receptionists',
        'Delete Receptionist',
        'Back to Main Menu',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        4,
        allowZero: false,
      );

      switch (choice) {
        case 1:
          await _createReceptionist();
          break;
        case 2:
          await _viewAllReceptionists();
          break;
        case 3:
          await _deleteReceptionist();
          break;
        case 4:
          return;
      }
    }
  }

  Future<void> _createReceptionist() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Create New Receptionist');

    try {
      final username = InputValidator.readString('Username (min 3 chars)');
      final password = InputValidator.readPassword('Password (min 6 chars)');
      final fullName = InputValidator.readString('Full Name');
      final phoneNumber = InputValidator.readPhoneNumber('Phone Number');

      print('\nSelect Shift:');
      ConsoleHelper.printMenu([
        'Morning (6:00 AM - 2:00 PM)',
        'Afternoon (2:00 PM - 10:00 PM)',
        'Evening (6:00 PM - 2:00 AM)',
        'Night (10:00 PM - 6:00 AM)',
      ]);
      final shiftChoice = InputValidator.readChoice('Select shift', 4);
      final shift = Shift.values[shiftChoice - 1];

      final adminId = _authService.currentUser!.id;

      final receptionist = await _userService.createReceptionist(
        username: username,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdByAdminId: adminId,
        shift: shift,
      );

      ConsoleHelper.printSuccess('Receptionist created successfully!');
      ConsoleHelper.printInfo('ID: ${receptionist.id}');
      ConsoleHelper.printInfo('Username: ${receptionist.username}');
      ConsoleHelper.printInfo('Shift: ${receptionist.shift.displayName}');
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewAllReceptionists() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('All Receptionists');

    try {
      final receptionists = await _userService.getAllReceptionists();

      if (receptionists.isEmpty) {
        ConsoleHelper.printInfo('No receptionists found');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Username', 'Full Name', 'Phone', 'Shift', 'Created'],
          [20, 15, 20, 18, 30, 12],
        );

        for (var receptionist in receptionists) {
          ConsoleHelper.printTableRow(
            [
              receptionist.id,
              receptionist.username,
              receptionist.fullName,
              receptionist.phoneNumber,
              receptionist.shift.displayName,
              ConsoleHelper.formatDate(receptionist.createdAt),
            ],
            [20, 15, 20, 18, 30, 12],
          );
        }

        print('\nTotal: ${receptionists.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _deleteReceptionist() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Delete Receptionist');

    try {
      final id = await _selectReceptionistByName();
      if (id == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      if (InputValidator.readConfirmation(
        'Are you sure you want to delete this receptionist?',
      )) {
        final deleted = await _userService.deleteReceptionist(id);

        if (deleted) {
          ConsoleHelper.printSuccess('Receptionist deleted successfully');
        } else {
          ConsoleHelper.printError('Receptionist not found');
        }
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  // ========== DOCTOR MANAGEMENT ==========
  Future<void> _manageDoctors() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Manage Doctors');

      ConsoleHelper.printMenu([
        'Create New Doctor (with Login Account)',
        'View All Doctors',
        'Search Doctor by Name',
        'Search Doctor by Specialization',
        'Delete Doctor',
        'Back to Main Menu',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        6,
        allowZero: false,
      );

      switch (choice) {
        case 1:
          await _createDoctorWithAccount();
          break;
        case 2:
          await _viewAllDoctors();
          break;
        case 3:
          await _searchDoctorByName();
          break;
        case 4:
          await _searchDoctorBySpecialization();
          break;
        case 5:
          await _deleteDoctor();
          break;
        case 6:
          return;
      }
    }
  }

  Future<void> _createDoctorWithAccount() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Create New Doctor with Login Account');

    try {
      // Step 1: Get doctor profile information
      ConsoleHelper.printInfo('Step 1: Doctor Profile Information\n');

      final name = InputValidator.readString('Doctor Name');
      final specialization = InputValidator.readString('Specialization');
      final department = InputValidator.readString('Department');

      print('\nSelect Shift:');
      ConsoleHelper.printMenu([
        'Morning (6:00 AM - 2:00 PM)',
        'Afternoon (2:00 PM - 10:00 PM)',
        'Evening (6:00 PM - 2:00 AM)',
        'Night (10:00 PM - 6:00 AM)',
      ]);
      final shiftChoice = InputValidator.readChoice('Select shift', 4);
      final shift = Shift.values[shiftChoice - 1];

      final phoneNumber = InputValidator.readPhoneNumber('Phone Number');
      final email = InputValidator.readEmail('Email');

      print('\nGender:');
      ConsoleHelper.printMenu(['Male', 'Female', 'Other']);
      final genderChoice = InputValidator.readChoice('Select gender', 3);
      final gender = Gender.values[genderChoice - 1];

      final experience = InputValidator.readInt(
        'Years of Experience',
        min: 0,
        max: 60,
      );

      // Step 2: Create doctor profile
      final doctor = await _doctorService.createDoctor(
        name: name,
        specialization: specialization,
        department: department,
        shift: shift,
        phoneNumber: phoneNumber,
        email: email,
        gender: gender,
        yearsOfExperience: experience,
      );

      ConsoleHelper.printSuccess('\n✓ Doctor profile created successfully!');
      ConsoleHelper.printInfo('ID: ${doctor.id}');
      ConsoleHelper.printInfo('Name: Dr. ${doctor.name}');
      ConsoleHelper.printInfo('Department: ${doctor.department}');
      ConsoleHelper.printInfo('Shift: ${doctor.shift.displayName}');

      // Step 3: Create login account
      print('\n');
      ConsoleHelper.printInfo('Step 2: Create Login Credentials\n');

      final username = InputValidator.readString('Username (min 3 chars)');
      final password = InputValidator.readPassword('Password (min 6 chars)');

      final doctorUser = await _userService.createDoctorUser(
        username: username,
        password: password,
        fullName: doctor.name,
        doctorId: doctor.id,
      );

      ConsoleHelper.printSuccess('\n✓ Doctor account created successfully!');
      ConsoleHelper.printInfo('Username: ${doctorUser.username}');
      ConsoleHelper.printInfo(
        'Dr. ${doctor.name} can now login with these credentials',
      );
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewAllDoctors() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('All Doctors');

    try {
      final doctors = await _doctorService.getAllDoctors();

      if (doctors.isEmpty) {
        ConsoleHelper.printInfo('No doctors found');
      } else {
        ConsoleHelper.printTableHeader(
          [
            'ID',
            'Name',
            'Specialization',
            'Department',
            'Shift',
            'Phone',
            'Exp',
          ],
          [20, 20, 20, 15, 18, 15, 5],
        );

        for (var doctor in doctors) {
          ConsoleHelper.printTableRow(
            [
              doctor.id,
              'Dr. ${doctor.name}',
              doctor.specialization,
              doctor.department,
              doctor.shift.displayName,
              doctor.phoneNumber,
              '${doctor.yearsOfExperience}y',
            ],
            [20, 20, 20, 15, 18, 15, 5],
          );
        }

        print('\nTotal: ${doctors.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _searchDoctorByName() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Search Doctor by Name');

    try {
      final name = InputValidator.readString('Enter doctor name');
      final allDoctors = await _doctorService.getAllDoctors();
      final doctors = allDoctors
          .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
          .toList();

      if (doctors.isEmpty) {
        ConsoleHelper.printInfo('No doctors found with that name');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Name', 'Specialization', 'Experience'],
          [20, 25, 25, 12],
        );

        for (var doctor in doctors) {
          ConsoleHelper.printTableRow(
            [
              doctor.id,
              'Dr. ${doctor.name}',
              doctor.specialization,
              '${doctor.yearsOfExperience} years',
            ],
            [20, 25, 25, 12],
          );
        }

        print('\nFound: ${doctors.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _searchDoctorBySpecialization() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Search Doctor by Specialization');

    try {
      final specialization = InputValidator.readString('Enter specialization');
      final doctors = await _doctorService.searchBySpecialization(
        specialization,
      );

      if (doctors.isEmpty) {
        ConsoleHelper.printInfo('No doctors found with that specialization');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Name', 'Specialization', 'Experience'],
          [20, 25, 25, 12],
        );

        for (var doctor in doctors) {
          ConsoleHelper.printTableRow(
            [
              doctor.id,
              'Dr. ${doctor.name}',
              doctor.specialization,
              '${doctor.yearsOfExperience} years',
            ],
            [20, 25, 25, 12],
          );
        }

        print('\nFound: ${doctors.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _deleteDoctor() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Delete Doctor');

    try {
      final id = await _selectDoctorByName();
      if (id == null) {
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      if (InputValidator.readConfirmation(
        'Are you sure you want to delete this doctor?',
      )) {
        final deleted = await _doctorService.deleteDoctor(id);

        if (deleted) {
          ConsoleHelper.printSuccess('Doctor deleted successfully');
        } else {
          ConsoleHelper.printError('Doctor not found');
        }
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  // ========== ROOM MANAGEMENT ==========
  Future<void> _manageRooms() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Manage Rooms');

      ConsoleHelper.printMenu([
        'Create New Room',
        'View All Rooms',
        'View Available Rooms',
        'Delete Room',
        'Back to Main Menu',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        5,
        allowZero: false,
      );

      switch (choice) {
        case 1:
          await _createRoom();
          break;
        case 2:
          await _viewAllRooms();
          break;
        case 3:
          await _viewAvailableRooms();
          break;
        case 4:
          await _deleteRoom();
          break;
        case 5:
          return;
      }
    }
  }

  Future<void> _createRoom() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Create New Room');

    try {
      final roomNumber = InputValidator.readString('Room Number');

      print('\nRoom Type:');
      ConsoleHelper.printMenu(['ICU', 'General', 'Private', 'Emergency']);
      final typeChoice = InputValidator.readChoice('Select type', 4);
      final type = RoomType.values[typeChoice - 1];

      final bedCount = InputValidator.readInt('Bed Count', min: 1, max: 10);
      final pricePerDay = InputValidator.readDouble('Price per Day', min: 0);

      final room = await _roomService.createRoom(
        roomNumber: roomNumber,
        type: type,
        bedCount: bedCount,
        pricePerDay: pricePerDay,
      );

      ConsoleHelper.printSuccess('Room created successfully!');
      ConsoleHelper.printInfo('Room Number: ${room.roomNumber}');
      ConsoleHelper.printInfo('Type: ${room.type.displayName}');
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewAllRooms() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('All Rooms');

    try {
      final rooms = await _roomService.getAllRooms();

      if (rooms.isEmpty) {
        ConsoleHelper.printInfo('No rooms found');
      } else {
        ConsoleHelper.printTableHeader(
          ['ID', 'Room #', 'Type', 'Status', 'Beds', 'Price/Day'],
          [20, 10, 30, 15, 6, 12],
        );

        for (var room in rooms) {
          ConsoleHelper.printTableRow(
            [
              room.id,
              room.roomNumber,
              room.type.displayName,
              room.status.displayName,
              '${room.bedCount}',
              '\$${room.pricePerDay.toStringAsFixed(2)}',
            ],
            [20, 10, 30, 15, 6, 12],
          );
        }

        print('\nTotal: ${rooms.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _viewAvailableRooms() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Available Rooms');

    try {
      final rooms = await _roomService.getAvailableRooms();

      if (rooms.isEmpty) {
        ConsoleHelper.printInfo('No available rooms');
      } else {
        ConsoleHelper.printTableHeader(
          ['Room #', 'Type', 'Beds', 'Price/Day'],
          [10, 30, 6, 12],
        );

        for (var room in rooms) {
          ConsoleHelper.printTableRow(
            [
              room.roomNumber,
              room.type.displayName,
              '${room.bedCount}',
              '\$${room.pricePerDay.toStringAsFixed(2)}',
            ],
            [10, 30, 6, 12],
          );
        }

        print('\nAvailable: ${rooms.length}');
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  Future<void> _deleteRoom() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printSection('Delete Room');

    try {
      await _viewAllRooms();

      final roomNumber = InputValidator.readString(
        'Enter Room Number to delete',
      );

      // Get room by room number
      final room = await _roomService.getRoomByRoomNumber(roomNumber);

      if (room == null) {
        ConsoleHelper.printError('Room not found');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Display room details
      print('\nRoom Details:');
      print('Room Number: ${room.roomNumber}');
      print('Type: ${room.type.displayName}');
      print('Status: ${room.status.displayName}');
      print('Beds: ${room.bedCount}');
      print('Price/Day: \$${room.pricePerDay.toStringAsFixed(2)}');

      if (InputValidator.readConfirmation(
        '\nAre you sure you want to delete this room?',
      )) {
        final deleted = await _roomService.deleteRoom(room.id);

        if (deleted) {
          ConsoleHelper.printSuccess('Room deleted successfully');
        } else {
          ConsoleHelper.printError('Failed to delete room');
        }
      }
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }

  // ========== STATISTICS ==========
  Future<void> _viewStatistics() async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printHeader('System Statistics');

    try {
      final receptionistCount = await _userService.getReceptionistCount();
      final doctorCount = await _doctorService.getDoctorCount();
      final patientCount = await _patientService.getPatientCount();
      final roomCount = await _roomService.getRoomCount();
      final availableRoomCount = await _roomService.getAvailableRoomCount();

      // Appointment statistics
      final scheduledAppointments = await _appointmentService
          .getScheduledAppointmentCount();
      final allAppointments = await _appointmentService.getAllAppointments();
      final completedAppointments = allAppointments
          .where((apt) => apt.status.name == 'completed')
          .length;

      print('═══════════════════════════════════════');
      print('  STAFF & RESOURCES');
      print('═══════════════════════════════════════');
      print('Total Receptionists: $receptionistCount');
      print('Total Doctors: $doctorCount');
      print('Total Patients: $patientCount');
      print('Total Rooms: $roomCount');
      print('Available Rooms: $availableRoomCount');
      print('');
      print('═══════════════════════════════════════');
      print('  APPOINTMENTS');
      print('═══════════════════════════════════════');
      print('Scheduled Appointments: $scheduledAppointments');
      print('Completed Appointments: $completedAppointments');
      print('Total Appointments: ${allAppointments.length}');
    } catch (e) {
      ConsoleHelper.printError(e.toString());
    }

    ConsoleHelper.pressEnterToContinue();
  }
}

import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../Domain/models/user.dart';
import '../../Domain/models/doctor.dart';
import '../../Domain/models/receptionist.dart';
import '../../Domain/enums/gender.dart';
import '../../Domain/enums/shift.dart';
import '../../Domain/enums/room_type.dart';
import '../../Domain/enums/room_status.dart';
import '../../Service/user_service.dart';
import '../../Service/room_service.dart';
import '../../Service/statistic_service.dart';
import '../utils/console_utils.dart';

class AdminMenu {
  final User _currentUser;
  final UserService _userService;
  final RoomService _roomService;
  final StatisticsService _statsService;
  final uuid = const Uuid();

  AdminMenu(
    this._currentUser,
    this._userService,
    this._roomService, 
    this._statsService,
  );

  void display() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n${'=' * 50}');
      print('ADMIN MENU - ${_currentUser.name}');
      print('=' * 50);
      print('1. Manage Doctors');
      print('2. Manage Receptionists');
      print('3. Manage Rooms');
      print('4. View Statistics');
      print('5. Logout');
      print('=' * 50);
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _manageDoctors();
          break;
        case '2':
          _manageReceptionists();
          break;
        case '3':
          _manageRooms();
          break;
        case '4':
          _statsService.displayAllStatistics();
          stdout.write('\nPress Enter to continue...');
          stdin.readLineSync();
          break;
        case '5':
          print('\nLogging out...');
          sleep(Duration(seconds: 1));
          return;
        default:
          print('\nInvalid option! Please try again.');
          sleep(Duration(seconds: 1));
      }
    }
  }

  // DOCTOR MANAGEMENT
  void _manageDoctors() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n--- MANAGE DOCTORS ---');
      print('1. Add Doctor');
      print('2. View All Doctors');
      print('3. Search Doctor by Name');
      print('4. Search Doctor by Specialization');
      print('5. Update Doctor');
      print('6. Delete Doctor');
      print('7. Back');
      stdout.write('Select an option: ');

      final choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          _addDoctor();
          break;
        case '2':
          _viewAllDoctors();
          break;
        case '3':
          _searchDoctorByName();
          break;
        case '4':
          _searchDoctorBySpecialization();
          break;
        case '5':
          _updateDoctor();
          break;
        case '6':
          _deleteDoctor();
          break;
        case '7':
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _addDoctor() {
    print('\n--- ADD DOCTOR ---');

    // Auto-generate Doctor ID
    final id = 'DOC-${uuid.v4().substring(0, 8).toUpperCase()}';
    print('Generated Doctor ID: $id');

    stdout.write('Enter Username: ');
    final username = stdin.readLineSync() ?? '';
    stdout.write('Enter Password (min 6 characters): ');
    final password = stdin.readLineSync() ?? '';
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
    stdout.write('Enter Phone (10 digits): ');
    final phone = stdin.readLineSync() ?? '';
    stdout.write('Enter Email: ');
    final email = stdin.readLineSync() ?? '';
    stdout.write('Enter Specialization: ');
    final specialization = stdin.readLineSync() ?? '';
    stdout.write('Enter Department: ');
    final department = stdin.readLineSync() ?? '';
    print('\nSelect Shift:');
    print('1. ${Shift.morning.displayName}');
    print('2. ${Shift.afternoon.displayName}');
    print('3. ${Shift.evening.displayName}');
    print('4. ${Shift.night.displayName}');
    stdout.write('Choice (1-4): ');
    final shiftChoice = stdin.readLineSync();
    final shift = shiftChoice == '1'
        ? Shift.morning
        : shiftChoice == '2'
        ? Shift.afternoon
        : shiftChoice == '3'
        ? Shift.evening
        : shiftChoice == '4'
        ? Shift.night
        : Shift.morning; // Default

    final success = _userService.addDoctor(
      id: id,
      username: username,
      password: password,
      name: name,
      gender: gender,
      phone: phone,
      email: email,
      specialization: specialization,
      department: department,
      shift: shift,
    );

    if (success) {
      print('\n✓ Doctor added successfully!');
    } else {
      print('\n✗ Failed to add doctor. Check validation or username exists.');
    }
  }

  void _viewAllDoctors() {
    final doctors = _userService.getAllDoctors();
    if (doctors.isEmpty) {
      print('\nNo doctors found.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }
    print('\n--- ALL DOCTORS ---');
    for (var doctor in doctors) {
      print('\n${'-' * 40}');
      doctor.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _searchDoctorByName() {
    stdout.write('\nEnter Doctor Name: ');
    final name = stdin.readLineSync() ?? '';

    final doctors = _userService.getAllDoctors();
    final matchingDoctors = doctors
        .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingDoctors.isEmpty) {
      print('\nNo doctors found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    print('\n--- SEARCH RESULTS ---');
    print('Found ${matchingDoctors.length} doctor(s):');
    for (var doctor in matchingDoctors) {
      print('\n${'-' * 40}');
      doctor.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _searchDoctorBySpecialization() {
    stdout.write('\nEnter Specialization: ');
    final specialization = stdin.readLineSync() ?? '';

    final matchingDoctors = _userService.searchDoctorsBySpecialization(
      specialization,
    );

    if (matchingDoctors.isEmpty) {
      print('\nNo doctors found with that specialization!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    print('\n--- SEARCH RESULTS ---');
    print('Found ${matchingDoctors.length} doctor(s):');
    for (var doctor in matchingDoctors) {
      print('\n${'-' * 40}');
      doctor.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _updateDoctor() {
    stdout.write('\nEnter Doctor Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for doctor by name
    final doctors = _userService.getAllDoctors();
    final matchingDoctors = doctors
        .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingDoctors.isEmpty) {
      print('No doctor found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Doctor? doctor;
    if (matchingDoctors.length == 1) {
      doctor = matchingDoctors.first;
    } else {
      // Multiple matches, let user choose
      print('\nMultiple doctors found:');
      for (int i = 0; i < matchingDoctors.length; i++) {
        print(
          '${i + 1}. ${matchingDoctors[i].name} (${matchingDoctors[i].id})',
        );
      }
      print('0. Cancel');
      stdout.write(
        'Select doctor (1-${matchingDoctors.length}, 0 to cancel): ',
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
      doctor = matchingDoctors[choice - 1];
    }

    print('\nCurrent Information:');
    doctor.displayInfo();
    print(
      '\nUpdate: 1. Password  2. Phone  3. Email  4. Specialization  5. Department  6. Shift',
    );
    stdout.write('Choice: ');
    final choice = stdin.readLineSync();

    bool updated = false;
    switch (choice) {
      case '1':
        stdout.write('Enter new password: ');
        final newPassword = stdin.readLineSync() ?? '';
        if (newPassword == doctor.password) {
          print('\n✗ New password is the same as current password!');
        } else if (newPassword.length >= 6) {
          doctor.password = newPassword;
          updated = _userService.updateDoctor(doctor);
        } else {
          print('\n✗ Invalid password! Must be at least 6 characters.');
        }
        break;
      case '2':
        stdout.write('Enter new phone: ');
        final newPhone = stdin.readLineSync() ?? '';
        if (newPhone == doctor.phone) {
          print('\n✗ New phone is the same as current phone!');
        } else if (RegExp(r'^\d{10}$').hasMatch(newPhone)) {
          final updatedDoctor = Doctor(
            id: doctor.id,
            username: doctor.username,
            password: doctor.password,
            name: doctor.name,
            gender: doctor.gender,
            phone: newPhone,
            email: doctor.email,
            specialization: doctor.specialization,
            department: doctor.department,
            shift: doctor.shift,
          );
          updated = _userService.updateDoctor(updatedDoctor);
        } else {
          print('\n✗ Invalid phone! Must be 10 digits.');
        }
        break;
      case '3':
        stdout.write('Enter new email: ');
        final newEmail = stdin.readLineSync() ?? '';
        if (newEmail == doctor.email) {
          print('\n✗ New email is the same as current email!');
        } else if (RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(newEmail)) {
          final updatedDoctor = Doctor(
            id: doctor.id,
            username: doctor.username,
            password: doctor.password,
            name: doctor.name,
            gender: doctor.gender,
            phone: doctor.phone,
            email: newEmail,
            specialization: doctor.specialization,
            department: doctor.department,
            shift: doctor.shift,
          );
          updated = _userService.updateDoctor(updatedDoctor);
        } else {
          print('\n✗ Invalid email format!');
        }
        break;
      case '4':
        stdout.write('Enter new specialization: ');
        final newSpec = stdin.readLineSync() ?? '';
        if (newSpec == doctor.specialization) {
          print(
            '\n✗ New specialization is the same as current specialization!',
          );
        } else if (newSpec.isEmpty) {
          print('\n✗ Specialization cannot be empty!');
        } else {
          final updatedDoctor = Doctor(
            id: doctor.id,
            username: doctor.username,
            password: doctor.password,
            name: doctor.name,
            gender: doctor.gender,
            phone: doctor.phone,
            email: doctor.email,
            specialization: newSpec,
            department: doctor.department,
            shift: doctor.shift,
          );
          updated = _userService.updateDoctor(updatedDoctor);
        }
        break;
      case '5':
        stdout.write('Enter new department: ');
        final newDept = stdin.readLineSync() ?? '';
        if (newDept == doctor.department) {
          print('\n✗ New department is the same as current department!');
        } else if (newDept.isEmpty) {
          print('\n✗ Department cannot be empty!');
        } else {
          final updatedDoctor = Doctor(
            id: doctor.id,
            username: doctor.username,
            password: doctor.password,
            name: doctor.name,
            gender: doctor.gender,
            phone: doctor.phone,
            email: doctor.email,
            specialization: doctor.specialization,
            department: newDept,
            shift: doctor.shift,
          );
          updated = _userService.updateDoctor(updatedDoctor);
        }
        break;
      case '6':
        print('\nSelect new shift:');
        print('1. ${Shift.morning.displayName}');
        print('2. ${Shift.afternoon.displayName}');
        print('3. ${Shift.evening.displayName}');
        print('4. ${Shift.night.displayName}');
        stdout.write('Choice (1-4): ');
        final shiftChoice = stdin.readLineSync();
        final newShift = shiftChoice == '1'
            ? Shift.morning
            : shiftChoice == '2'
            ? Shift.afternoon
            : shiftChoice == '3'
            ? Shift.evening
            : shiftChoice == '4'
            ? Shift.night
            : null;

        if (newShift == null) {
          print('\n✗ Invalid shift selection!');
        } else if (newShift == doctor.shift) {
          print('\n✗ New shift is the same as current shift!');
        } else {
          final updatedDoctor = Doctor(
            id: doctor.id,
            username: doctor.username,
            password: doctor.password,
            name: doctor.name,
            gender: doctor.gender,
            phone: doctor.phone,
            email: doctor.email,
            specialization: doctor.specialization,
            department: doctor.department,
            shift: newShift,
          );
          updated = _userService.updateDoctor(updatedDoctor);
        }
        break;
    }
    print(updated ? '\n✓ Updated successfully!' : '\n✗ Update failed!');
  }

  void _deleteDoctor() {
    stdout.write('\nEnter Doctor Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for doctor by name
    final doctors = _userService.getAllDoctors();
    final matchingDoctors = doctors
        .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingDoctors.isEmpty) {
      print('No doctor found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Doctor? doctor;
    if (matchingDoctors.length == 1) {
      doctor = matchingDoctors.first;
    } else {
      // Multiple matches, let user choose
      print('\nMultiple doctors found:');
      for (int i = 0; i < matchingDoctors.length; i++) {
        print(
          '${i + 1}. ${matchingDoctors[i].name} (${matchingDoctors[i].id})',
        );
      }
      print('0. Cancel');
      stdout.write(
        'Select doctor (1-${matchingDoctors.length}, 0 to cancel): ',
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
      doctor = matchingDoctors[choice - 1];
    }

    print('\nDoctor Information:');
    doctor.displayInfo();
    stdout.write('\nConfirm deletion? (yes/no): ');
    final confirm = stdin.readLineSync()?.toLowerCase();
    if (confirm == 'yes') {
      print(
        _userService.deleteDoctor(doctor.id)
            ? '\n✓ Deleted successfully!'
            : '\n✗ Deletion failed!',
      );
    } else {
      print('Deletion cancelled.');
    }
  }

  // RECEPTIONIST MANAGEMENT
  void _manageReceptionists() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n--- MANAGE RECEPTIONISTS ---');
      print('1. Add Receptionist');
      print('2. View All Receptionists');
      print('3. Search Receptionist by Name');
      print('4. Update Receptionist');
      print('5. Delete Receptionist');
      print('6. Back');
      stdout.write('Select an option: ');
      final choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          _addReceptionist();
          break;
        case '2':
          _viewAllReceptionists();
          break;
        case '3':
          _searchReceptionistByName();
          break;
        case '4':
          _updateReceptionist();
          break;
        case '5':
          _deleteReceptionist();
          break;
        case '6':
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _addReceptionist() {
    print('\n--- ADD RECEPTIONIST ---');

    // Auto-generate Receptionist ID
    final id = 'REC-${uuid.v4().substring(0, 8).toUpperCase()}';
    print('Generated Receptionist ID: $id');

    stdout.write('Enter Username: ');
    final username = stdin.readLineSync() ?? '';
    stdout.write('Enter Password (min 6 characters): ');
    final password = stdin.readLineSync() ?? '';
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
    stdout.write('Enter Phone (10 digits): ');
    final phone = stdin.readLineSync() ?? '';
    stdout.write('Enter Email: ');
    final email = stdin.readLineSync() ?? '';
    print('\nSelect Shift:');
    print('1. ${Shift.morning.displayName}');
    print('2. ${Shift.afternoon.displayName}');
    print('3. ${Shift.evening.displayName}');
    print('4. ${Shift.night.displayName}');
    stdout.write('Choice (1-4): ');
    final shiftChoice = stdin.readLineSync();
    final shift = shiftChoice == '1'
        ? Shift.morning
        : shiftChoice == '2'
        ? Shift.afternoon
        : shiftChoice == '3'
        ? Shift.evening
        : shiftChoice == '4'
        ? Shift.night
        : Shift.morning; // Default

    final success = _userService.addReceptionist(
      id: id,
      username: username,
      password: password,
      name: name,
      gender: gender,
      phone: phone,
      email: email,
      shift: shift,
    );
    print(
      success
          ? '\n✓ Receptionist added successfully!'
          : '\n✗ Failed to add receptionist.',
    );
  }

  void _viewAllReceptionists() {
    final receptionists = _userService.getAllReceptionists();
    if (receptionists.isEmpty) {
      print('\nNo receptionists found.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }
    print('\n--- ALL RECEPTIONISTS ---');
    for (var r in receptionists) {
      print('\n${'-' * 40}');
      r.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _searchReceptionistByName() {
    stdout.write('\nEnter Receptionist Name: ');
    final name = stdin.readLineSync() ?? '';

    final receptionists = _userService.getAllReceptionists();
    final matchingRecs = receptionists
        .where((r) => r.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingRecs.isEmpty) {
      print('\nNo receptionists found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    print('\n--- SEARCH RESULTS ---');
    print('Found ${matchingRecs.length} receptionist(s):');
    for (var receptionist in matchingRecs) {
      print('\n${'-' * 40}');
      receptionist.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _updateReceptionist() {
    stdout.write('\nEnter Receptionist Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for receptionist by name
    final receptionists = _userService.getAllReceptionists();
    final matchingRecs = receptionists
        .where((r) => r.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingRecs.isEmpty) {
      print('No receptionist found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Receptionist? rec;
    if (matchingRecs.length == 1) {
      rec = matchingRecs.first;
    } else {
      // Multiple matches, let user choose
      print('\nMultiple receptionists found:');
      for (int i = 0; i < matchingRecs.length; i++) {
        print('${i + 1}. ${matchingRecs[i].name} (${matchingRecs[i].id})');
      }
      print('0. Cancel');
      stdout.write(
        'Select receptionist (1-${matchingRecs.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');
      if (choice == null || choice < 0 || choice > matchingRecs.length) {
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
      rec = matchingRecs[choice - 1];
    }

    print('\nCurrent Information:');
    rec.displayInfo();
    print('\nUpdate: 1. Password  2. Phone  3. Email  4. Shift');
    stdout.write('Choice: ');
    final choice = stdin.readLineSync();

    bool updated = false;
    switch (choice) {
      case '1':
        stdout.write('Enter new password: ');
        final newPassword = stdin.readLineSync() ?? '';
        if (newPassword.length < 6) {
          print('Invalid password! Must be at least 6 characters.');
        } else if (newPassword == rec.password) {
          print('New password is the same as the current password!');
        } else {
          final updatedRec = Receptionist(
            id: rec.id,
            username: rec.username,
            password: newPassword,
            name: rec.name,
            gender: rec.gender,
            phone: rec.phone,
            email: rec.email,
            shift: rec.shift,
          );
          updated = _userService.updateReceptionist(updatedRec);
        }
        break;
      case '2':
        stdout.write('Enter new phone number: ');
        final newPhone = stdin.readLineSync() ?? '';
        if (!RegExp(r'^\d{10}$').hasMatch(newPhone)) {
          print('Invalid phone number! Must be 10 digits.');
        } else if (newPhone == rec.phone) {
          print('New phone number is the same as the current phone number!');
        } else {
          final updatedRec = Receptionist(
            id: rec.id,
            username: rec.username,
            password: rec.password,
            name: rec.name,
            gender: rec.gender,
            phone: newPhone,
            email: rec.email,
            shift: rec.shift,
          );
          updated = _userService.updateReceptionist(updatedRec);
        }
        break;
      case '3':
        stdout.write('Enter new email: ');
        final newEmail = stdin.readLineSync() ?? '';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
          print('Invalid email format!');
        } else if (newEmail == rec.email) {
          print('New email is the same as the current email!');
        } else {
          final updatedRec = Receptionist(
            id: rec.id,
            username: rec.username,
            password: rec.password,
            name: rec.name,
            gender: rec.gender,
            phone: rec.phone,
            email: newEmail,
            shift: rec.shift,
          );
          updated = _userService.updateReceptionist(updatedRec);
        }
        break;
      case '4':
        print('\nSelect new shift:');
        print('1. ${Shift.morning.displayName}');
        print('2. ${Shift.afternoon.displayName}');
        print('3. ${Shift.evening.displayName}');
        print('4. ${Shift.night.displayName}');
        stdout.write('Choice (1-4): ');
        final shiftChoice = stdin.readLineSync();
        final newShift = shiftChoice == '1'
            ? Shift.morning
            : shiftChoice == '2'
            ? Shift.afternoon
            : shiftChoice == '3'
            ? Shift.evening
            : shiftChoice == '4'
            ? Shift.night
            : null;
        if (newShift == null) {
          print('Invalid shift selection!');
        } else if (newShift == rec.shift) {
          print('New shift is the same as the current shift!');
        } else {
          final updatedRec = Receptionist(
            id: rec.id,
            username: rec.username,
            password: rec.password,
            name: rec.name,
            gender: rec.gender,
            phone: rec.phone,
            email: rec.email,
            shift: newShift,
          );
          updated = _userService.updateReceptionist(updatedRec);
        }
        break;
      default:
        print('Invalid choice!');
    }
    print(updated ? '\n✓ Updated successfully!' : '\n✗ Update failed!');
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _deleteReceptionist() {
    stdout.write('\nEnter Receptionist Name: ');
    final name = stdin.readLineSync() ?? '';

    // Search for receptionist by name
    final receptionists = _userService.getAllReceptionists();
    final matchingRecs = receptionists
        .where((r) => r.name.toLowerCase().contains(name.toLowerCase()))
        .toList();

    if (matchingRecs.isEmpty) {
      print('No receptionist found with that name!');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }

    Receptionist? rec;
    if (matchingRecs.length == 1) {
      rec = matchingRecs.first;
    } else {
      // Multiple matches, let user choose
      print('\nMultiple receptionists found:');
      for (int i = 0; i < matchingRecs.length; i++) {
        print('${i + 1}. ${matchingRecs[i].name} (${matchingRecs[i].id})');
      }
      print('0. Cancel');
      stdout.write(
        'Select receptionist (1-${matchingRecs.length}, 0 to cancel): ',
      );
      final choice = int.tryParse(stdin.readLineSync() ?? '');
      if (choice == null || choice < 0 || choice > matchingRecs.length) {
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
      rec = matchingRecs[choice - 1];
    }

    rec.displayInfo();
    stdout.write('\nConfirm deletion? (yes/no): ');
    if (stdin.readLineSync()?.toLowerCase() == 'yes') {
      print(
        _userService.deleteReceptionist(rec.id)
            ? '\n✓ Deleted!'
            : '\n✗ Failed!',
      );
    } else {
      print('Deletion cancelled.');
    }
  }

  // ROOM MANAGEMENT
  void _manageRooms() {
    while (true) {
      ConsoleUtils.clearScreen();
      print('\n--- MANAGE ROOMS ---');
      print('1. Add Room');
      print('2. View All Rooms');
      print('3. Update Room Status');
      print('4. Delete Room');
      print('5. Back');
      stdout.write('Select an option: ');
      final choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          _addRoom();
          break;
        case '2':
          _viewAllRooms();
          break;
        case '3':
          _updateRoomStatus();
          break;
        case '4':
          _deleteRoom();
          break;
        case '5':
          return;
        default:
          print('\nInvalid option!');
          sleep(Duration(seconds: 1));
      }
    }
  }

  void _addRoom() {
    print('\n--- ADD ROOM ---');
    stdout.write('Enter Room ID (e.g., RM001): ');
    final id = stdin.readLineSync() ?? '';
    stdout.write('Enter Room Number: ');
    final roomNumber = stdin.readLineSync() ?? '';
    print('Select Type: 1. General  2. Private  3. ICU  4. Emergency');
    stdout.write('Choice: ');
    final typeChoice = stdin.readLineSync();
    final type = typeChoice == '1'
        ? RoomType.general
        : typeChoice == '2'
        ? RoomType.private
        : typeChoice == '3'
        ? RoomType.icu
        : RoomType.emergency;
    stdout.write('Enter Bed Count: ');
    final bedCount = int.tryParse(stdin.readLineSync() ?? '1') ?? 1;

    final success = _roomService.addRoom(
      id: id,
      roomNumber: roomNumber,
      type: type,
      bedCount: bedCount,
    );
    print(success ? '\n✓ Room added successfully!' : '\n✗ Failed to add room.');
  }

  void _viewAllRooms() {
    final rooms = _roomService.getAllRooms();
    if (rooms.isEmpty) {
      print('\nNo rooms found.');
      stdout.write('\nPress Enter to continue...');
      stdin.readLineSync();
      return;
    }
    print('\n--- ALL ROOMS ---');
    for (var room in rooms) {
      print('\n${'-' * 40}');
      room.displayInfo();
    }
    print('-' * 40);
    stdout.write('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  void _updateRoomStatus() {
    stdout.write('\nEnter Room Number: ');
    final roomNumber = stdin.readLineSync() ?? '';
    final room = _roomService.getRoomByRoomNumber(roomNumber);
    if (room == null) {
      print('Room not found!');
      return;
    }
    print('\nCurrent Information:');
    room.displayInfo();
    print('\nSelect Status: 1. Available  2. Occupied  3. Maintenance');
    stdout.write('Choice: ');
    final statusChoice = stdin.readLineSync();
    final newStatus = statusChoice == '1'
        ? RoomStatus.available
        : statusChoice == '2'
        ? RoomStatus.occupied
        : RoomStatus.maintenance;

    final updated = _roomService.updateRoomStatus(roomNumber, newStatus);
    print(updated ? '\n✓ Status updated!' : '\n✗ Update failed!');
  }

  void _deleteRoom() {
    stdout.write('\nEnter Room Number: ');
    final roomNumber = stdin.readLineSync() ?? '';
    final room = _roomService.getRoomByRoomNumber(roomNumber);
    if (room == null) {
      print('Room not found!');
      return;
    }
    room.displayInfo();
    stdout.write('\nConfirm? (yes/no): ');
    if (stdin.readLineSync()?.toLowerCase() == 'yes') {
      print(
        _roomService.deleteRoom(roomNumber)
            ? '\n✓ Deleted!'
            : '\n✗ Cannot delete occupied room!',
      );
    }
  }
}

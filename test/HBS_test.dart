import 'package:test/test.dart';
import '../lib/Domain/models/admin.dart';
import '../lib/Domain/models/doctor.dart';
import '../lib/Domain/models/receptionist.dart';
import '../lib/Domain/models/patient.dart';
import '../lib/Domain/models/appointment.dart';
import '../lib/Domain/models/room.dart';
import '../lib/Domain/enums/gender.dart';
import '../lib/Domain/enums/shift.dart';
import '../lib/Domain/enums/appointment_status.dart';
import '../lib/Domain/enums/room_type.dart';
import '../lib/Domain/enums/room_status.dart';
import '../lib/Data/Repositories/user_repository.dart';
import '../lib/Data/Repositories/patient_repository.dart';
import '../lib/Data/Repositories/appointment_repository.dart';
import '../lib/Data/Repositories/room_repository.dart';
import '../lib/Service/auth_service.dart';
import '../lib/Service/user_service.dart';
import '../lib/Service/patient_service.dart';
import '../lib/Service/appointment_service.dart';
import '../lib/Service/room_service.dart';
import '../lib/Service/validation_service.dart';

void main() {
  group('User Model Tests', () {
    test('Test 1: Admin Creation and Properties', () {
      final admin = Admin(
        id: 'ADM001',
        username: 'admin_test',
        password: 'Pass123',
        name: 'Test Admin',
        gender: Gender.male,
        phone: '1234567890',
        email: 'admin@test.com',
      );

      expect(admin.id, equals('ADM001'));
      expect(admin.username, equals('admin_test'));
      expect(admin.name, equals('Test Admin'));
      expect(admin.role.name, equals('admin'));
    });

    test('Test 2: Doctor Creation with Specialization', () {
      final doctor = Doctor(
        id: 'DOC001',
        username: 'doctor_test',
        password: 'Pass123',
        name: 'Dr. Smith',
        gender: Gender.male,
        phone: '9876543210',
        email: 'doctor@test.com',
        specialization: 'Cardiology',
        department: 'Cardiology Department',
      );

      expect(doctor.specialization, equals('Cardiology'));
      expect(doctor.department, equals('Cardiology Department'));
      expect(doctor.role.name, equals('doctor'));
    });

    test('Test 3: Receptionist Creation with Shift', () {
      final receptionist = Receptionist(
        id: 'REC001',
        username: 'receptionist_test',
        password: 'Pass123',
        name: 'Jane Doe',
        gender: Gender.female,
        phone: '5551234567',
        email: 'receptionist@test.com',
        shift: Shift.morning,
      );

      expect(receptionist.shift, equals(Shift.morning));
      expect(receptionist.role.name, equals('receptionist'));
    });
  });

  group('Patient Model Tests', () {
    test('Test 4: Patient Age Calculation', () {
      final patient = Patient(
        id: 'PAT001',
        name: 'John Patient',
        gender: Gender.male,
        age: 34,
        phoneNumber: '1231231234',
        address: '123 Main St',
        registrationDate: DateTime.now(),
      );

      expect(patient.age, equals(34));
      expect(patient.id, equals('PAT001'));
    });

    test('Test 5: Patient with Medical History', () {
      final patient = Patient(
        id: 'PAT002',
        name: 'Sarah Patient',
        gender: Gender.female,
        age: 39,
        phoneNumber: '3213213210',
        address: '456 Oak Ave',
        medicalHistory: 'Diabetes, Hypertension',
        registrationDate: DateTime.now(),
      );

      expect(patient.medicalHistory, equals('Diabetes, Hypertension'));
      expect(patient.medicalHistory, isNotNull);
    });
  });

  group('Appointment Tests', () {
    test('Test 6: Appointment Creation and Status', () {
      final appointment = Appointment(
        id: 'APT001',
        patientId: 'PAT001',
        doctorId: 'DOC001',
        dateTime: DateTime.now().add(Duration(days: 1)),
        reason: 'Regular checkup',
      );

      expect(appointment.status, equals(AppointmentStatus.scheduled));
      expect(appointment.reason, equals('Regular checkup'));
    });

    test('Test 7: Appointment Status Update', () {
      final appointment = Appointment(
        id: 'APT002',
        patientId: 'PAT002',
        doctorId: 'DOC001',
        dateTime: DateTime.now().add(Duration(hours: 2)),
        reason: 'Follow-up',
      );

      appointment.status = AppointmentStatus.completed;
      appointment.notes = 'Patient recovered well';

      expect(appointment.status, equals(AppointmentStatus.completed));
      expect(appointment.notes, equals('Patient recovered well'));
    });
  });

  group('Room Tests', () {
    test('Test 8: Room Creation and Properties', () {
      final room = Room(
        id: 'RM001',
        roomNumber: '101',
        type: RoomType.private,
        bedCount: 2,
      );

      expect(room.status, equals(RoomStatus.available));
      expect(room.type, equals(RoomType.private));
      expect(room.bedCount, equals(2));
    });

    test('Test 9: Room Status Change', () {
      final room = Room(
        id: 'RM002',
        roomNumber: '201',
        type: RoomType.icu,
        bedCount: 1,
      );

      room.status = RoomStatus.occupied;
      room.patientId = 'PAT001';

      expect(room.status, equals(RoomStatus.occupied));
      expect(room.patientId, equals('PAT001'));
    });
  });

  group('Validation Service Tests', () {
    test('Test 10: Validation Service - Email, Phone, Password', () {
      // Valid email
      expect(ValidationService.isValidEmail('test@example.com'), isTrue);
      expect(ValidationService.isValidEmail('invalid-email'), isFalse);

      // Valid phone (10 digits)
      expect(ValidationService.isValidPhone('1234567890'), isTrue);
      expect(ValidationService.isValidPhone('123'), isFalse);

      // Valid password (min 6 characters)
      expect(ValidationService.isValidPassword('Pass123'), isTrue);
      expect(ValidationService.isValidPassword('12345'), isFalse);

      // Valid username (min 3 characters, no spaces)
      expect(ValidationService.isValidUsername('user123'), isTrue);
      expect(ValidationService.isValidUsername('ab'), isFalse);
      expect(ValidationService.isValidUsername('user name'), isFalse);

      // Valid date
      expect(ValidationService.isValidDate('2024-01-15'), isTrue);
      expect(ValidationService.isValidDate('invalid-date'), isFalse);
    });
  });

  // SERVICE LAYER TESTS
  group('Service Layer Tests', () {
    late UserRepository userRepo;
    late PatientRepository patientRepo;
    late AppointmentRepository appointmentRepo;
    late RoomRepository roomRepo;
    late UserService userService;
    late PatientService patientService;
    late AppointmentService appointmentService;
    late RoomService roomService;

    setUp(() {
      userRepo = UserRepository();
      patientRepo = PatientRepository();
      appointmentRepo = AppointmentRepository();
      roomRepo = RoomRepository();

      userService = UserService(userRepo);
      patientService = PatientService(patientRepo);
      appointmentService = AppointmentService(
        appointmentRepo,
        patientRepo,
        userRepo,
      );
      roomService = RoomService(roomRepo);
    });

    test('Test 11: UserService - Add Doctor', () {
      final success = userService.addDoctor(
        id: 'DOC_TEST001',
        username: 'test_doctor',
        password: 'Pass123',
        name: 'Test Doctor',
        gender: Gender.male,
        phone: '1234567890',
        email: 'testdoc@test.com',
        specialization: 'Surgery',
        department: 'Surgery Department',
      );

      expect(success, isTrue);
      final doctor = userService.getDoctorById('DOC_TEST001');
      expect(doctor, isNotNull);
      expect(doctor?.specialization, equals('Surgery'));

      // Cleanup
      userService.deleteDoctor('DOC_TEST001');
    });

    test('Test 12: PatientService - Add and Retrieve Patient', () {
      final success = patientService.addPatient(
        id: 'PAT_TEST001',
        name: 'Test Patient',
        gender: Gender.female,
        age: 34,
        phoneNumber: '9876543210',
        address: 'Test Address',
        medicalHistory: 'None',
      );

      expect(success, isTrue);
      final patient = patientService.getPatientById('PAT_TEST001');
      expect(patient, isNotNull);
      expect(patient?.name, equals('Test Patient'));

      // Cleanup
      patientService.deletePatient('PAT_TEST001');
    });

    test('Test 13: AppointmentService - Create Appointment', () {
      // First add doctor and patient
      userService.addDoctor(
        id: 'DOC_TEST002',
        username: 'test_doctor2',
        password: 'Pass123',
        name: 'Test Doctor 2',
        gender: Gender.male,
        phone: '1111111111',
        email: 'testdoc2@test.com',
        specialization: 'General',
        department: 'General Medicine',
      );

      patientService.addPatient(
        id: 'PAT_TEST002',
        name: 'Test Patient 2',
        gender: Gender.male,
        age: 29,
        phoneNumber: '2222222222',
        address: 'Test Address 2',
      );

      final success = appointmentService.createAppointment(
        id: 'APT_TEST001',
        patientId: 'PAT_TEST002',
        doctorId: 'DOC_TEST002',
        dateTime: DateTime.now().add(Duration(days: 1)),
        reason: 'Checkup',
      );

      expect(success, isTrue);
      final appointment = appointmentService.getAppointmentById('APT_TEST001');
      expect(appointment, isNotNull);
      expect(appointment?.reason, equals('Checkup'));

      // Cleanup
      appointmentService.deleteAppointment('APT_TEST001');
      userService.deleteDoctor('DOC_TEST002');
      patientService.deletePatient('PAT_TEST002');
    });

    test('Test 14: RoomService - Add and Update Room', () {
      final success = roomService.addRoom(
        id: 'RM_TEST001',
        roomNumber: '999',
        type: RoomType.general,
        bedCount: 4,
      );

      expect(success, isTrue);
      final room = roomService.getRoomById('RM_TEST001');
      expect(room, isNotNull);
      expect(room?.bedCount, equals(4));

      // Update status using room number
      final updated = roomService.updateRoomStatus(
        '999',
        RoomStatus.maintenance,
      );
      expect(updated, isTrue);

      final updatedRoom = roomService.getRoomById('RM_TEST001');
      expect(updatedRoom?.status, equals(RoomStatus.maintenance));

      // Cleanup using room number
      roomService.deleteRoom('999');
    });

    test('Test 15: AuthenticationService - Login', () {
      final authService = AuthenticationService(userRepo);

      // Test default admin login
      final user = authService.login('Admin', 'Admin123');

      expect(user, isNotNull);
      expect(user?.username, equals('Admin'));
      expect(user?.role.name, equals('admin'));
    });
  });
}

import 'package:test/test.dart';
import 'package:hbs_mini_project/Domain/models/admin.dart';
import 'package:hbs_mini_project/Domain/models/patient.dart';
import 'package:hbs_mini_project/Domain/models/appointment.dart';
import 'package:hbs_mini_project/Domain/enums/gender.dart';
import 'package:hbs_mini_project/Domain/enums/appointment_status.dart';
import 'package:hbs_mini_project/Domain/enums/room_type.dart';
import 'package:hbs_mini_project/Domain/enums/room_status.dart';
import 'package:hbs_mini_project/Data/Repositories/user_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/patient_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/appointment_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/room_repository.dart';
import 'package:hbs_mini_project/Data/Storage/json_storage.dart';
import 'package:hbs_mini_project/Service/user_service.dart';
import 'package:hbs_mini_project/Service/patient_service.dart';
import 'package:hbs_mini_project/Service/appointment_service.dart';
import 'package:hbs_mini_project/Service/room_service.dart';

void main() {
  group('Hospital Management System Tests', () {
    late UserRepository userRepo;
    late PatientRepository patientRepo;
    late AppointmentRepository appointmentRepo;
    late RoomRepository roomRepo;
    late UserService userService;
    late PatientService patientService;
    late AppointmentService appointmentService;
    late RoomService roomService;

    setUp(() {
      // Clear all storage files before each test
      JsonStorage('admins.json').clear();
      JsonStorage('doctors.json').clear();
      JsonStorage('receptionists.json').clear();
      JsonStorage('patients.json').clear();
      JsonStorage('appointments.json').clear();
      JsonStorage('rooms.json').clear();

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

    tearDown(() {
      // Clear all storage files after each test
      JsonStorage('admins.json').clear();
      JsonStorage('doctors.json').clear();
      JsonStorage('receptionists.json').clear();
      JsonStorage('patients.json').clear();
      JsonStorage('appointments.json').clear();
      JsonStorage('rooms.json').clear();
    });

    test(
      'should validate user fields correctly for valid and invalid inputs',
      () {
        // Create test user instance for validation
        final validUser = Admin(
          id: 'ADM001',
          username: 'admin_user',
          password: 'Pass123',
          name: 'Test Admin',
          gender: Gender.male,
          phone: '1234567890',
          email: 'admin@test.com',
        );

        final invalidUser = Admin(
          id: 'A1',
          username: 'ab',
          password: '123',
          name: 'T',
          gender: Gender.male,
          phone: '123',
          email: 'invalid-email',
        );

        // Test valid user
        expect(validUser.isValidEmail(), isTrue);
        expect(validUser.isValidPhone(), isTrue);
        expect(validUser.isValidPassword(), isTrue);
        expect(validUser.isValidUsername(), isTrue);
        expect(validUser.isValidId(), isTrue);
        expect(validUser.isValidName(), isTrue);

        // Test invalid user
        expect(invalidUser.isValidEmail(), isFalse);
        expect(invalidUser.isValidPhone(), isFalse);
        expect(invalidUser.isValidPassword(), isFalse);
        expect(invalidUser.isValidUsername(), isFalse);
        expect(invalidUser.isValidName(), isFalse);
      },
    );

    test(
      'should validate appointment fields and check date/time helper functions',
      () {
        final futureAppointment = Appointment(
          id: 'APT001',
          patientId: 'PAT001',
          doctorId: 'DOC001',
          dateTime: DateTime.now().add(Duration(days: 1)),
          reason: 'Regular checkup',
        );

        final pastAppointment = Appointment(
          id: 'APT002',
          patientId: 'PAT002',
          doctorId: 'DOC001',
          dateTime: DateTime.now().subtract(Duration(days: 1)),
          reason: 'Follow-up',
        );

        // Test validation functions
        expect(futureAppointment.isValidId(), isTrue);
        expect(futureAppointment.isValidReason(), isTrue);
        expect(futureAppointment.isValidDateTime(), isTrue);

        // Test helper functions
        expect(futureAppointment.isFuture(), isTrue);
        expect(futureAppointment.isPast(), isFalse);
        expect(futureAppointment.isScheduled(), isTrue);

        expect(pastAppointment.isPast(), isTrue);
        expect(pastAppointment.isFuture(), isFalse);
        expect(pastAppointment.isValidDateTime(), isFalse);
      },
    );

    test(
      'should filter appointments by patient ID and doctor ID correctly',
      () {
        // Setup: Add doctor and patients
        userService.addDoctor(
          id: 'DOC_FILTER001',
          username: 'dr_filter',
          password: 'Pass123',
          name: 'Filter Doctor',
          gender: Gender.male,
          phone: '1111111111',
          email: 'filterdoc@test.com',
          specialization: 'General',
          department: 'General Medicine',
        );

        patientService.addPatient(
          id: 'PAT_FILTER001',
          name: 'Filter Patient 1',
          gender: Gender.male,
          age: 30,
          phoneNumber: '2222222222',
          address: 'Address 1',
        );

        patientService.addPatient(
          id: 'PAT_FILTER002',
          name: 'Filter Patient 2',
          gender: Gender.female,
          age: 25,
          phoneNumber: '3333333333',
          address: 'Address 2',
        );

        // Create appointments
        appointmentService.createAppointment(
          id: 'APT_FILTER001',
          patientId: 'PAT_FILTER001',
          doctorId: 'DOC_FILTER001',
          dateTime: DateTime.now().add(Duration(days: 1)),
          reason: 'Checkup',
        );

        appointmentService.createAppointment(
          id: 'APT_FILTER002',
          patientId: 'PAT_FILTER002',
          doctorId: 'DOC_FILTER001',
          dateTime: DateTime.now().add(Duration(days: 2)),
          reason: 'Follow-up',
        );

        appointmentService.createAppointment(
          id: 'APT_FILTER003',
          patientId: 'PAT_FILTER001',
          doctorId: 'DOC_FILTER001',
          dateTime: DateTime.now().add(Duration(days: 3)),
          reason: 'Surgery',
        );

        // Test filter by patient
        final patient1Appointments = appointmentService
            .getAppointmentsByPatientId('PAT_FILTER001');
        expect(patient1Appointments.length, equals(2));

        // Test filter by doctor
        final doctorAppointments = appointmentService.getAppointmentsByDoctorId(
          'DOC_FILTER001',
        );
        expect(doctorAppointments.length, equals(3));

        // Cleanup
        appointmentService.deleteAppointment('APT_FILTER001');
        appointmentService.deleteAppointment('APT_FILTER002');
        appointmentService.deleteAppointment('APT_FILTER003');
        userService.deleteDoctor('DOC_FILTER001');
        patientService.deletePatient('PAT_FILTER001');
        patientService.deletePatient('PAT_FILTER002');
      },
    );

    test('should calculate appointment statistics by status correctly', () {
      // Setup
      userService.addDoctor(
        id: 'DOC_STAT001',
        username: 'dr_statistics',
        password: 'Pass123',
        name: 'Stat Doctor',
        gender: Gender.male,
        phone: '4444444444',
        email: 'statdoc@test.com',
        specialization: 'General',
        department: 'General Medicine',
      );

      patientService.addPatient(
        id: 'PAT_STAT001',
        name: 'Stat Patient 1',
        gender: Gender.male,
        age: 30,
        phoneNumber: '5555555555',
        address: 'Address 1',
      );

      patientService.addPatient(
        id: 'PAT_STAT002',
        name: 'Stat Patient 2',
        gender: Gender.female,
        age: 25,
        phoneNumber: '6666666666',
        address: 'Address 2',
      );

      patientService.addPatient(
        id: 'PAT_STAT003',
        name: 'Stat Patient 3',
        gender: Gender.male,
        age: 40,
        phoneNumber: '7777777777',
        address: 'Address 3',
      );

      // Create appointments with different statuses
      appointmentService.createAppointment(
        id: 'APT_STAT001',
        patientId: 'PAT_STAT001',
        doctorId: 'DOC_STAT001',
        dateTime: DateTime.now().add(Duration(days: 1)),
        reason: 'Checkup',
      );

      appointmentService.createAppointment(
        id: 'APT_STAT002',
        patientId: 'PAT_STAT002',
        doctorId: 'DOC_STAT001',
        dateTime: DateTime.now().add(Duration(days: 2)),
        reason: 'Follow-up',
      );

      appointmentService.createAppointment(
        id: 'APT_STAT003',
        patientId: 'PAT_STAT003',
        doctorId: 'DOC_STAT001',
        dateTime: DateTime.now().add(Duration(days: 3)),
        reason: 'Surgery',
      );

      // Update one to completed
      appointmentService.updateAppointmentStatus(
        'APT_STAT001',
        AppointmentStatus.completed,
        'Completed successfully',
      );

      // Update one to cancelled
      appointmentService.updateAppointmentStatus(
        'APT_STAT002',
        AppointmentStatus.cancelled,
        'Cancelled by patient',
      );

      // Test statistics
      final stats = appointmentService.getAppointmentStatistics();
      expect(stats[AppointmentStatus.scheduled], equals(1));
      expect(stats[AppointmentStatus.completed], equals(1));
      expect(stats[AppointmentStatus.cancelled], equals(1));

      // Cleanup
      appointmentService.deleteAppointment('APT_STAT001');
      appointmentService.deleteAppointment('APT_STAT002');
      appointmentService.deleteAppointment('APT_STAT003');
      userService.deleteDoctor('DOC_STAT001');
      patientService.deletePatient('PAT_STAT001');
      patientService.deletePatient('PAT_STAT002');
      patientService.deletePatient('PAT_STAT003');
    });

    test('should add a new doctor and retrieve doctor by ID successfully', () {
      final success = userService.addDoctor(
        id: 'DOC_TEST001',
        username: 'dr_smith',
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
      expect(doctor?.name, equals('Test Doctor'));

      // Cleanup
      userService.deleteDoctor('DOC_TEST001');
    });

    test(
      'should add a new patient and retrieve patient by ID successfully',
      () {
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
        expect(patient?.age, equals(34));
        expect(patient?.gender, equals(Gender.female));

        // Cleanup
        patientService.deletePatient('PAT_TEST001');
      },
    );

    test('should update patient information successfully', () {
      // Add patient first
      patientService.addPatient(
        id: 'PAT_TEST002',
        name: 'Test Patient 2',
        gender: Gender.male,
        age: 25,
        phoneNumber: '1111111111',
        address: 'Test Address',
      );

      // Get patient and update
      final patient = patientService.getPatientById('PAT_TEST002');
      expect(patient, isNotNull);

      // Create updated patient instance
      final updatedPatient = Patient(
        id: patient!.id,
        name: patient.name,
        gender: patient.gender,
        age: 26,
        phoneNumber: '2222222222',
        address: 'New Address',
        medicalHistory: 'Updated History',
        registrationDate: patient.registrationDate,
      );

      final success = patientService.updatePatient(updatedPatient);
      expect(success, isTrue);

      final updated = patientService.getPatientById('PAT_TEST002');
      expect(updated?.age, equals(26));
      expect(updated?.phoneNumber, equals('2222222222'));
      expect(updated?.address, equals('New Address'));

      // Cleanup
      patientService.deletePatient('PAT_TEST002');
    });

    test('should create a new appointment with valid patient and doctor', () {
      // Setup: Add doctor and patient
      userService.addDoctor(
        id: 'DOC_TEST002',
        username: 'dr_jones',
        password: 'Pass123',
        name: 'Test Doctor 2',
        gender: Gender.male,
        phone: '1111111111',
        email: 'testdoc2@test.com',
        specialization: 'General',
        department: 'General Medicine',
      );

      patientService.addPatient(
        id: 'PAT_TEST003',
        name: 'Test Patient 3',
        gender: Gender.male,
        age: 29,
        phoneNumber: '2222222222',
        address: 'Test Address 3',
      );

      // Test createAppointment function
      final success = appointmentService.createAppointment(
        id: 'APT_TEST001',
        patientId: 'PAT_TEST003',
        doctorId: 'DOC_TEST002',
        dateTime: DateTime.now().add(Duration(days: 1)),
        reason: 'Checkup',
      );

      expect(success, isTrue);

      final appointment = appointmentService.getAppointmentById('APT_TEST001');
      expect(appointment, isNotNull);
      expect(appointment?.reason, equals('Checkup'));
      expect(appointment?.status, equals(AppointmentStatus.scheduled));
      expect(appointment?.patientId, equals('PAT_TEST003'));
      expect(appointment?.doctorId, equals('DOC_TEST002'));

      // Cleanup
      appointmentService.deleteAppointment('APT_TEST001');
      userService.deleteDoctor('DOC_TEST002');
      patientService.deletePatient('PAT_TEST003');
    });

    test('should update appointment status and notes successfully', () {
      // Setup
      userService.addDoctor(
        id: 'DOC_TEST003',
        username: 'dr_williams',
        password: 'Pass123',
        name: 'Test Doctor 3',
        gender: Gender.female,
        phone: '3333333333',
        email: 'testdoc3@test.com',
        specialization: 'Pediatrics',
        department: 'Pediatrics',
      );

      patientService.addPatient(
        id: 'PAT_TEST004',
        name: 'Test Patient 4',
        gender: Gender.female,
        age: 30,
        phoneNumber: '4444444444',
        address: 'Test Address 4',
      );

      appointmentService.createAppointment(
        id: 'APT_TEST002',
        patientId: 'PAT_TEST004',
        doctorId: 'DOC_TEST003',
        dateTime: DateTime.now().add(Duration(days: 2)),
        reason: 'Follow-up',
      );

      // Test updateAppointmentStatus function
      final success = appointmentService.updateAppointmentStatus(
        'APT_TEST002',
        AppointmentStatus.completed,
        'Treatment completed successfully',
      );

      expect(success, isTrue);

      final updated = appointmentService.getAppointmentById('APT_TEST002');
      expect(updated?.status, equals(AppointmentStatus.completed));
      expect(updated?.notes, equals('Treatment completed successfully'));

      // Cleanup
      appointmentService.deleteAppointment('APT_TEST002');
      userService.deleteDoctor('DOC_TEST003');
      patientService.deletePatient('PAT_TEST004');
    });

    test(
      'should add room, assign patient to room, and release room successfully',
      () {
        // Test adding a room
        final addRoomSuccess = roomService.addRoom(
          id: 'RM_TEST001',
          roomNumber: '101',
          type: RoomType.general,
          bedCount: 2,
          status: RoomStatus.available,
        );

        expect(addRoomSuccess, isTrue);

        final room = roomService.getRoomById('RM_TEST001');
        expect(room, isNotNull);
        expect(room?.roomNumber, equals('101'));
        expect(room?.type, equals(RoomType.general));
        expect(room?.bedCount, equals(2));
        expect(room?.status, equals(RoomStatus.available));
        expect(room?.isAvailable(), isTrue);

        // Add a patient
        patientService.addPatient(
          id: 'PAT_ROOM001',
          name: 'Room Patient',
          gender: Gender.male,
          age: 45,
          phoneNumber: '5555555555',
          address: 'Test Address',
        );

        // Test assigning patient to room
        final assignSuccess = roomService.assignPatientToRoom(
          'RM_TEST001',
          'PAT_ROOM001',
        );
        expect(assignSuccess, isTrue);

        final assignedRoom = roomService.getRoomById('RM_TEST001');
        expect(assignedRoom?.status, equals(RoomStatus.occupied));
        expect(assignedRoom?.patientId, equals('PAT_ROOM001'));
        expect(assignedRoom?.isOccupied(), isTrue);

        // Test releasing room
        final releaseSuccess = roomService.releaseRoom('RM_TEST001');
        expect(releaseSuccess, isTrue);

        final releasedRoom = roomService.getRoomById('RM_TEST001');
        expect(releasedRoom?.status, equals(RoomStatus.available));
        expect(releasedRoom?.patientId, isNull);
        expect(releasedRoom?.isAvailable(), isTrue);

        // Cleanup
        roomService.deleteRoom('101');
        patientService.deletePatient('PAT_ROOM001');
      },
    );
  });
}

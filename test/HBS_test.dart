import 'package:test/test.dart';
import '../lib/Domain/models/admin.dart';
import '../lib/Domain/models/doctor.dart';
import '../lib/Domain/models/patient.dart';
import '../lib/Domain/models/appointment.dart';
import '../lib/Domain/enums/gender.dart';
import '../lib/Domain/enums/appointment_status.dart';
import '../lib/Data/Repositories/user_repository.dart';
import '../lib/Data/Repositories/patient_repository.dart';
import '../lib/Data/Repositories/appointment_repository.dart';
import '../lib/Service/auth_service.dart';
import '../lib/Service/user_service.dart';
import '../lib/Service/patient_service.dart';
import '../lib/Service/appointment_service.dart';

void main() {
  group('Validation Function Tests', () {
    test('Test 1: User Validation Functions', () {
      // Create test user instance for validation
      final validUser = Admin(
        id: 'ADM001',
        username: 'admin_test',
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
    });

    test('Test 2: Appointment Validation and Helper Functions', () {
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
    });

    test('Test 3: Appointment Static Filter Functions', () {
      final appointments = [
        Appointment(
          id: 'APT001',
          patientId: 'PAT001',
          doctorId: 'DOC001',
          dateTime: DateTime.now().add(Duration(days: 1)),
          reason: 'Checkup',
          status: AppointmentStatus.scheduled,
        ),
        Appointment(
          id: 'APT002',
          patientId: 'PAT002',
          doctorId: 'DOC001',
          dateTime: DateTime.now().add(Duration(days: 2)),
          reason: 'Follow-up',
          status: AppointmentStatus.completed,
        ),
        Appointment(
          id: 'APT003',
          patientId: 'PAT001',
          doctorId: 'DOC002',
          dateTime: DateTime.now().add(Duration(days: 3)),
          reason: 'Surgery',
          status: AppointmentStatus.scheduled,
        ),
      ];

      // Test filter functions
      final patient1Appointments = Appointment.filterByPatient(
        appointments,
        'PAT001',
      );
      expect(patient1Appointments.length, equals(2));

      final doctor1Appointments = Appointment.filterByDoctor(
        appointments,
        'DOC001',
      );
      expect(doctor1Appointments.length, equals(2));

      final scheduledAppointments = Appointment.filterByStatus(
        appointments,
        AppointmentStatus.scheduled,
      );
      expect(scheduledAppointments.length, equals(2));

      final completedAppointments = Appointment.filterByStatus(
        appointments,
        AppointmentStatus.completed,
      );
      expect(completedAppointments.length, equals(1));
    });

    test('Test 4: Appointment Statistics Function', () {
      final appointments = [
        Appointment(
          id: 'APT001',
          patientId: 'PAT001',
          doctorId: 'DOC001',
          dateTime: DateTime.now().add(Duration(days: 1)),
          reason: 'Checkup',
          status: AppointmentStatus.scheduled,
        ),
        Appointment(
          id: 'APT002',
          patientId: 'PAT002',
          doctorId: 'DOC001',
          dateTime: DateTime.now().add(Duration(days: 2)),
          reason: 'Follow-up',
          status: AppointmentStatus.completed,
        ),
        Appointment(
          id: 'APT003',
          patientId: 'PAT003',
          doctorId: 'DOC001',
          dateTime: DateTime.now().add(Duration(days: 3)),
          reason: 'Surgery',
          status: AppointmentStatus.cancelled,
        ),
      ];

      final stats = Appointment.getStatistics(appointments);

      expect(stats[AppointmentStatus.scheduled], equals(1));
      expect(stats[AppointmentStatus.completed], equals(1));
      expect(stats[AppointmentStatus.cancelled], equals(1));
    });
  });

  // SERVICE LAYER TESTS - Testing Service Functions
  group('Service Layer Function Tests', () {
    late UserRepository userRepo;
    late PatientRepository patientRepo;
    late AppointmentRepository appointmentRepo;
    late UserService userService;
    late PatientService patientService;
    late AppointmentService appointmentService;

    setUp(() {
      userRepo = UserRepository();
      patientRepo = PatientRepository();
      appointmentRepo = AppointmentRepository();

      userService = UserService(userRepo);
      patientService = PatientService(patientRepo);
      appointmentService = AppointmentService(
        appointmentRepo,
        patientRepo,
        userRepo,
      );
    });

    test('Test 5: UserService - addDoctor() and getDoctorById() Functions', () {
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

    test(
      'Test 6: PatientService - addPatient() and getPatientById() Functions',
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

        // Cleanup
        patientService.deletePatient('PAT_TEST001');
      },
    );

    test('Test 7: PatientService - updatePatient() Function', () {
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

    test('Test 8: AppointmentService - createAppointment() Function', () {
      // Setup: Add doctor and patient
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

      // Cleanup
      appointmentService.deleteAppointment('APT_TEST001');
      userService.deleteDoctor('DOC_TEST002');
      patientService.deletePatient('PAT_TEST003');
    });

    test('Test 9: AppointmentService - updateAppointmentStatus() Function', () {
      // Setup
      userService.addDoctor(
        id: 'DOC_TEST003',
        username: 'test_doctor3',
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

    test('Test 10: AuthenticationService - login() Function', () {
      final authService = AuthenticationService(userRepo);

      // Test default admin login function
      final user = authService.login('Admin', 'Admin123');

      expect(user, isNotNull);
      expect(user?.username, equals('Admin'));
      expect(user?.role.name, equals('admin'));

      // Test invalid login
      final invalidUser = authService.login('Invalid', 'WrongPass');
      expect(invalidUser, isNull);
    });
  });
}

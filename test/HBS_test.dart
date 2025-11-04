import 'package:flutter_test/flutter_test.dart';
import 'package:hbs_mini_project/Domain/models/patient.dart';
import 'package:hbs_mini_project/Domain/enums/gender.dart';
import 'package:hbs_mini_project/Domain/enums/appointment_status.dart';
import 'package:hbs_mini_project/Domain/enums/room_type.dart';
import 'package:hbs_mini_project/Domain/enums/room_status.dart';
import 'package:hbs_mini_project/Service/patient_service.dart';
import 'package:hbs_mini_project/Service/doctor_service.dart';
import 'package:hbs_mini_project/Service/appointment_service.dart';
import 'package:hbs_mini_project/Service/room_service.dart';
import 'package:hbs_mini_project/Service/auth_service.dart';
import 'package:hbs_mini_project/Data/Repositories/patient_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/doctor_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/appointment_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/room_repository.dart';
import 'package:hbs_mini_project/Data/Repositories/user_repository.dart';
import 'package:hbs_mini_project/Data/Storage/json_storage.dart';

void main() {
  group('Hospital Management System - Integration Tests', () {
    late JsonStorage storage;
    late PatientRepository patientRepository;
    late DoctorRepository doctorRepository;
    late AppointmentRepository appointmentRepository;
    late RoomRepository roomRepository;
    late UserRepository userRepository;
    late PatientService patientService;
    late DoctorService doctorService;
    late AppointmentService appointmentService;
    late RoomService roomService;
    late AuthService authService;

    setUp(() async {
      // Initialize storage and repositories
      storage = JsonStorage();
      patientRepository = PatientRepository(storage);
      doctorRepository = DoctorRepository(storage);
      appointmentRepository = AppointmentRepository(storage);
      roomRepository = RoomRepository(storage);
      userRepository = UserRepository(storage);

      // Initialize services
      patientService = PatientService(patientRepository);
      doctorService = DoctorService(doctorRepository);
      appointmentService = AppointmentService(
        appointmentRepository,
        patientRepository,
        doctorRepository,
        roomRepository,
      );
      roomService = RoomService(roomRepository, patientRepository);
      authService = AuthService(userRepository);

      // Clear all data before each test
      await storage.clearJsonFile('patients.json');
      await storage.clearJsonFile('doctors.json');
      await storage.clearJsonFile('appointments.json');
      await storage.clearJsonFile('rooms.json');
      await storage.clearJsonFile('users.json');
    });

    test(
      'Test 1: Complete Patient Registration and Management Workflow',
      () async {
        // Create a patient
        final patient = await patientService.createPatient(
          name: 'Chealean',
          age: 35,
          gender: Gender.male,
          phoneNumber: '1234567890',
          address: 'Phnom Penh',
          medicalHistory: 'No known allergies',
        );

        // Verify patient was created
        expect(patient.name, 'Chealean');
        expect(patient.age, 35);
        expect(patient.phoneNumber, '1234567890');

        // Retrieve patient from repository
        final retrievedPatient = await patientService.getPatientById(
          patient.id,
        );
        expect(retrievedPatient, isNotNull);
        expect(retrievedPatient!.name, 'Chealean');

        // Get all patients
        final allPatients = await patientService.getAllPatients();
        expect(allPatients.length, 1);

        // Update patient
        final updatedPatient = Patient(
          id: patient.id,
          name: 'Chealean Updated',
          age: 36,
          gender: patient.gender,
          phoneNumber: patient.phoneNumber,
          address: patient.address,
          medicalHistory: 'Updated medical history',
          registrationDate: patient.registrationDate,
        );
        await patientService.updatePatient(updatedPatient);

        // Verify update
        final afterUpdate = await patientService.getPatientById(patient.id);
        expect(afterUpdate!.name, 'Chealean Updated');
        expect(afterUpdate.age, 36);

        // Delete patient
        final deleted = await patientService.deletePatient(patient.id);
        expect(deleted, true);

        // Verify deletion
        final afterDelete = await patientService.getPatientById(patient.id);
        expect(afterDelete, isNull);
      },
    );

    test('Test 2: Doctor Registration and Specialization Search', () async {
      // Create multiple doctors with different specializations
      await doctorService.createDoctor(
        name: 'Dr. Nia',
        specialization: 'Cardiology',
        department: 'Heart Department',
        shift: 'Morning',
        phoneNumber: '1111111111',
        email: 'nia@hospital.com',
        gender: Gender.female,
        yearsOfExperience: 10,
      );

      await doctorService.createDoctor(
        name: 'Dr. Jay',
        specialization: 'Neurology',
        department: 'Brain Department',
        shift: 'Evening',
        phoneNumber: '2222222222',
        email: 'jay@hospital.com',
        gender: Gender.male,
        yearsOfExperience: 15,
      );

      await doctorService.createDoctor(
        name: 'Dr. Zane',
        specialization: 'Pediatrics',
        department: 'Children Department',
        shift: 'Morning',
        phoneNumber: '3333333333',
        email: 'zane@hospital.com',
        gender: Gender.male,
        yearsOfExperience: 8,
      );

      // Verify doctors were created
      final allDoctors = await doctorService.getAllDoctors();
      expect(allDoctors.length, 3);

      // Search by specialization
      final cardiologists = await doctorService.searchBySpecialization(
        'Cardiology',
      );
      expect(cardiologists.length, 1);
      expect(cardiologists[0].name, 'Dr. Nia');

      // Get doctors sorted by experience
      final sortedDoctors = await doctorService.getDoctorsSortedByExperience();
      expect(sortedDoctors[0].yearsOfExperience, 15); // Most experienced first
      expect(sortedDoctors[2].yearsOfExperience, 8); // Least experienced last
    });

    test('Test 3: Room Management and Availability', () async {
      // Create different types of rooms
      await roomService.createRoom(
        roomNumber: 'R101',
        type: RoomType.general,
        bedCount: 4,
        pricePerDay: 50.0,
      );

      await roomService.createRoom(
        roomNumber: 'R201',
        type: RoomType.private,
        bedCount: 1,
        pricePerDay: 150.0,
      );

      await roomService.createRoom(
        roomNumber: 'ICU-R301',
        type: RoomType.icu,
        bedCount: 1,
        pricePerDay: 250.0,
      );

      // Verify rooms were created
      final allRooms = await roomService.getAllRooms();
      expect(allRooms.length, 3);

      // Get available rooms
      final availableRooms = await roomService.getAvailableRooms();
      expect(availableRooms.length, 3);

      // Get rooms by type
      final generalRooms = await roomService.getRoomsByType(RoomType.general);
      expect(generalRooms.length, 1);
      expect(generalRooms[0].roomNumber, 'R101');

      // Verify room count
      final roomCount = await roomService.getRoomCount();
      expect(roomCount, 3);

      // Get occupied room count
      final occupiedCount = await roomService.getOccupiedRoomCount();
      expect(occupiedCount, 0);
    });

    test(
      'Test 4: Complete Appointment Workflow from Creation to Completion',
      () async {
        // Setup: Create patient, doctor, and room
        final patient = await patientService.createPatient(
          name: 'Cole',
          age: 28,
          gender: Gender.male,
          phoneNumber: '5555555555',
          address: '456 Oak Avenue',
        );

        final doctor = await doctorService.createDoctor(
          name: 'Dr. Wu',
          specialization: 'General Medicine',
          department: 'General Department',
          shift: 'Morning',
          phoneNumber: '6666666666',
          email: 'wu@hospital.com',
          gender: Gender.male,
          yearsOfExperience: 12,
        );

        final room = await roomService.createRoom(
          roomNumber: 'R301',
          type: RoomType.general,
          bedCount: 1,
          pricePerDay: 75.0,
        );

        // Create appointment
        final appointmentDate = DateTime.now().add(
          Duration(days: 2, hours: 10),
        );
        final appointment = await appointmentService.createAppointment(
          patientId: patient.id,
          doctorId: doctor.id,
          roomId: room.id,
          appointmentDate: appointmentDate,
          reason: 'Regular health checkup',
        );

        // Verify appointment was created
        expect(appointment.status, AppointmentStatus.scheduled);
        expect(appointment.reason, 'Regular health checkup');

        // Get upcoming appointments
        final upcomingAppointments = await appointmentService
            .getUpcomingAppointments();
        expect(upcomingAppointments.length, 1);

        // Complete appointment
        await appointmentService.completeAppointment(
          appointment.id,
          notes: 'Patient is healthy. No issues found.',
        );

        final completedAppointment = await appointmentService
            .getAppointmentById(appointment.id);
        expect(completedAppointment!.status, AppointmentStatus.completed);
        expect(
          completedAppointment.notes,
          'Patient is healthy. No issues found.',
        );
      },
    );

    test('Test 5: Appointment Scheduling Conflict Detection', () async {
      // Setup
      final patient1 = await patientService.createPatient(
        name: 'Patient One',
        age: 30,
        gender: Gender.male,
        phoneNumber: '7777777777',
        address: '789 Pine Street',
      );

      final patient2 = await patientService.createPatient(
        name: 'Patient Two',
        age: 25,
        gender: Gender.female,
        phoneNumber: '8888888888',
        address: '321 Elm Street',
      );

      final doctor = await doctorService.createDoctor(
        name: 'Dr. Liz',
        specialization: 'Internal Medicine',
        department: 'General Department',
        shift: 'Morning',
        phoneNumber: '9999999999',
        email: 'liz@hospital.com',
        gender: Gender.female,
        yearsOfExperience: 9,
      );

      final room = await roomService.createRoom(
        roomNumber: '501',
        type: RoomType.general,
        bedCount: 1,
        pricePerDay: 75.0,
      );

      // Create first appointment
      final appointmentDate = DateTime.now().add(Duration(days: 3, hours: 14));
      final appointment1 = await appointmentService.createAppointment(
        patientId: patient1.id,
        doctorId: doctor.id,
        roomId: room.id,
        appointmentDate: appointmentDate,
        reason: 'First appointment',
      );

      expect(appointment1, isNotNull);

      // Try to create conflicting appointment (same doctor, same time)
      try {
        await appointmentService.createAppointment(
          patientId: patient2.id,
          doctorId: doctor.id,
          roomId: room.id,
          appointmentDate: appointmentDate.add(Duration(minutes: 30)),
          reason: 'Conflicting appointment',
        );
        fail('Should throw exception for conflicting appointment');
      } catch (e) {
        expect(e.toString(), contains('already has an appointment'));
      }
    });

    test('Test 6: Authentication and User Management System', () async {
      // Initialize auth service (creates default admin)
      await authService.initialize();

      // Login as admin
      final admin = await authService.login('admin', 'admin123');
      expect(admin, isNotNull);
      expect(authService.isLoggedIn, true);
      expect(authService.isAdmin, true);

      // Check admin permissions
      expect(authService.canManageDoctors(), true);
      expect(authService.canManagePatients(), true);
      expect(authService.canManageRooms(), true);

      // Logout
      authService.logout();
      expect(authService.isLoggedIn, false);
      expect(authService.currentUser, isNull);

      // Try invalid login
      try {
        await authService.login('admin', 'wrongpassword');
        fail('Should throw exception for invalid credentials');
      } catch (e) {
        expect(e.toString(), contains('Invalid credentials'));
      }
    });

    test('Test 7: Patient Search and Filter Functionality', () async {
      // Create multiple patients
      await patientService.createPatient(
        name: 'Khalid',
        age: 12,
        gender: Gender.male,
        phoneNumber: '1111111111',
        address: '111 First Street',
      );

      await patientService.createPatient(
        name: 'Leo Messi',
        age: 70,
        gender: Gender.female,
        phoneNumber: '2222222222',
        address: '222 Second Street',
      );

      await patientService.createPatient(
        name: 'Ronaldo',
        age: 35,
        gender: Gender.male,
        phoneNumber: '3333333333',
        address: '333 Third Street',
      );

      // Search by name
      final mesiPatients = await patientService.searchPatientsByName('Messi');
      expect(mesiPatients.length, 1);
      expect(mesiPatients[0].name, 'Leo Messi');

      // Get kid patients (age < 18)
      final kidPatients = await patientService.getKidPatients();
      expect(kidPatients.length, 1);
      expect(kidPatients[0].name, 'Khalid');

      // Get elderly patients (age >= 65)
      final elderlyPatients = await patientService.getElderlyPatients();
      expect(elderlyPatients.length, 1);
      expect(elderlyPatients[0].name, 'Leo Messi');

      // Get total patient count
      final count = await patientService.getPatientCount();
      expect(count, 3);
    });

    test('Test 8: Appointment Rescheduling', () async {
      // Setup
      final patient = await patientService.createPatient(
        name: 'Test Patient',
        age: 40,
        gender: Gender.male,
        phoneNumber: '4444444444',
        address: '444 Fourth Street',
      );

      final doctor = await doctorService.createDoctor(
        name: 'Dr. Test Doctor',
        specialization: 'Surgery',
        department: 'Surgery Department',
        shift: 'Evening',
        phoneNumber: '5555555555',
        email: 'test.doctor@hospital.com',
        gender: Gender.male,
        yearsOfExperience: 20,
      );

      final room = await roomService.createRoom(
        roomNumber: 'SUR-101',
        type: RoomType.general,
        bedCount: 1,
        pricePerDay: 200.0,
      );

      // Create original appointment
      final originalDate = DateTime.now().add(Duration(days: 5, hours: 9));
      final appointment = await appointmentService.createAppointment(
        patientId: patient.id,
        doctorId: doctor.id,
        roomId: room.id,
        appointmentDate: originalDate,
        reason: 'Surgical consultation',
      );

      // Reschedule appointment
      final newDate = DateTime.now().add(Duration(days: 7, hours: 14));
      await appointmentService.rescheduleAppointment(appointment.id, newDate);

      // Verify rescheduling
      final rescheduledAppointment = await appointmentService
          .getAppointmentById(appointment.id);
      expect(rescheduledAppointment!.appointmentDate, newDate);
      expect(rescheduledAppointment.status, AppointmentStatus.scheduled);
    });

    test('Test 9: Room Maintenance and Status Management', () async {
      // Create room
      final room = await roomService.createRoom(
        roomNumber: 'MAINT-101',
        type: RoomType.private,
        bedCount: 1,
        pricePerDay: 250.0,
      );

      expect(room.status, RoomStatus.available);

      // Set to maintenance
      await roomService.setRoomToMaintenance(room.id);
      final maintenanceRoom = await roomService.getRoomById(room.id);
      expect(maintenanceRoom!.status, RoomStatus.maintenance);

      // Get available rooms should not include maintenance rooms
      final availableRooms = await roomService.getAvailableRooms();
      expect(availableRooms.where((r) => r.id == room.id).length, 0);

      // Verify occupied room count remains 0
      final occupiedRoomCount = await roomService.getOccupiedRoomCount();
      expect(occupiedRoomCount, 0);
    });

    test(
      'Test 10: Multiple Appointments for Different Patients with Same Doctor',
      () async {
        // Setup
        final patient1 = await patientService.createPatient(
          name: 'Patient 1',
          age: 45,
          gender: Gender.male,
          phoneNumber: '1010101010',
          address: '101 Street',
        );

        final patient2 = await patientService.createPatient(
          name: 'Patient 2',
          age: 32,
          gender: Gender.female,
          phoneNumber: '2020202020',
          address: '202 Street',
        );

        final doctor = await doctorService.createDoctor(
          name: 'Dr. Busy Physician',
          specialization: 'Family Medicine',
          department: 'General Department',
          shift: 'Full Day',
          phoneNumber: '3030303030',
          email: 'busy.physician@hospital.com',
          gender: Gender.female,
          yearsOfExperience: 15,
        );

        final room1 = await roomService.createRoom(
          roomNumber: 'R110',
          type: RoomType.general,
          bedCount: 1,
          pricePerDay: 100.0,
        );

        final room2 = await roomService.createRoom(
          roomNumber: 'R111',
          type: RoomType.general,
          bedCount: 1,
          pricePerDay: 100.0,
        );

        // Create appointments at different times (2 hours apart)
        await appointmentService.createAppointment(
          patientId: patient1.id,
          doctorId: doctor.id,
          roomId: room1.id,
          appointmentDate: DateTime.now().add(Duration(days: 1, hours: 9)),
          reason: 'Morning consultation',
        );

        await appointmentService.createAppointment(
          patientId: patient2.id,
          doctorId: doctor.id,
          roomId: room2.id,
          appointmentDate: DateTime.now().add(Duration(days: 1, hours: 11)),
          reason: 'Late morning consultation',
        );

        // Get appointments by doctor
        final doctorAppointments = await appointmentService
            .getAppointmentsByDoctor(doctor.id);
        expect(doctorAppointments.length, 2);
      },
    );

    test('Test 11: Appointment Cancellation and Statistics', () async {
      // Setup
      final patient = await patientService.createPatient(
        name: 'Cancel Test Patient',
        age: 50,
        gender: Gender.male,
        phoneNumber: '4040404040',
        address: '404 Street',
      );

      final doctor = await doctorService.createDoctor(
        name: 'Dr. Cancel',
        specialization: 'Dermatology',
        department: 'Skin Department',
        shift: 'Morning',
        phoneNumber: '5050505050',
        email: 'cancel@hospital.com',
        gender: Gender.female,
        yearsOfExperience: 7,
      );

      final room = await roomService.createRoom(
        roomNumber: 'DERM-101',
        type: RoomType.general,
        bedCount: 1,
        pricePerDay: 150.0,
      );

      // Create multiple appointments
      final appointment1 = await appointmentService.createAppointment(
        patientId: patient.id,
        doctorId: doctor.id,
        roomId: room.id,
        appointmentDate: DateTime.now().add(Duration(days: 2)),
        reason: 'Skin consultation',
      );

      await appointmentService.createAppointment(
        patientId: patient.id,
        doctorId: doctor.id,
        roomId: room.id,
        appointmentDate: DateTime.now().add(Duration(days: 5)),
        reason: 'Follow-up consultation',
      );

      // Cancel one appointment
      await appointmentService.cancelAppointment(appointment1.id);

      // Verify cancellation
      final cancelledAppointment = await appointmentService.getAppointmentById(
        appointment1.id,
      );
      expect(cancelledAppointment!.status, AppointmentStatus.cancelled);

      // Get scheduled appointment count
      final scheduledCount = await appointmentService
          .getScheduledAppointmentCount();
      expect(scheduledCount, 1);

      // Get all appointments count
      final totalCount = await appointmentService.getAppointmentCount();
      expect(totalCount, 2);
    });

    test('Test 12: End-to-End Hospital System Integration', () async {
      // This test simulates a complete hospital workflow

      // 1. Initialize system and login as admin
      await authService.initialize();
      await authService.login('admin', 'admin123');
      expect(authService.isAdmin, true);

      // 2. Register a new patient
      final patient = await patientService.createPatient(
        name: 'Another TEST PATIENT',
        age: 42,
        gender: Gender.female,
        phoneNumber: '6060606060',
        address: '606 Avenue',
        medicalHistory: 'Diabetes, controlled with medication',
      );

      // 3. Add a doctor to the system
      final doctor = await doctorService.createDoctor(
        name: 'Dr. Integration Specialist',
        specialization: 'Endocrinology',
        department: 'Diabetes Care',
        shift: 'Morning',
        phoneNumber: '7070707070',
        email: 'integration.specialist@hospital.com',
        gender: Gender.male,
        yearsOfExperience: 18,
      );

      // 4. Create consultation rooms
      final consultationRoom = await roomService.createRoom(
        roomNumber: 'R211',
        type: RoomType.private,
        bedCount: 1,
        pricePerDay: 200.0,
      );

      // 5. Schedule an appointment
      final appointmentDate = DateTime.now().add(Duration(days: 3, hours: 10));
      final appointment = await appointmentService.createAppointment(
        patientId: patient.id,
        doctorId: doctor.id,
        roomId: consultationRoom.id,
        appointmentDate: appointmentDate,
        reason: 'Diabetes management consultation',
      );

      // 6. Verify appointment is in upcoming appointments
      final upcomingAppointments = await appointmentService
          .getUpcomingAppointments();
      expect(upcomingAppointments.any((apt) => apt.id == appointment.id), true);

      // 7. Mark room as occupied
      await roomService.assignPatientToRoom(consultationRoom.id, patient.id);

      // 8. Complete the appointment
      await appointmentService.completeAppointment(
        appointment.id,
        notes:
            'Patient blood sugar levels are stable. Continue current medication. Follow-up in 3 months.',
      );

      // 9. Release the room
      await roomService.releasePatientFromRoom(consultationRoom.id);

      // 10. Verify final state
      final finalAppointment = await appointmentService.getAppointmentById(
        appointment.id,
      );
      expect(finalAppointment!.status, AppointmentStatus.completed);
      expect(finalAppointment.notes, contains('stable'));

      final finalRoom = await roomService.getRoomById(consultationRoom.id);
      expect(finalRoom!.status, RoomStatus.available);
      expect(finalRoom.currentPatientId, isNull);

      // 11. Get system statistics
      final totalPatients = await patientService.getPatientCount();
      final totalDoctors = await doctorService.getDoctorCount();
      final totalAppointments = await appointmentService.getAppointmentCount();
      final totalRooms = (await roomService.getAllRooms()).length;

      expect(totalPatients, greaterThan(0));
      expect(totalDoctors, greaterThan(0));
      expect(totalAppointments, greaterThan(0));
      expect(totalRooms, greaterThan(0));

      // 12. Logout
      authService.logout();
      expect(authService.isLoggedIn, false);
    });
  });
}

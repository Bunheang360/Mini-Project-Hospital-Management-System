# Hospital Management System

A comprehensive console-based Hospital Management System built with Flutter/Dart, designed to manage doctors, patients, appointments, and rooms efficiently.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Use Cases](#use-cases)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)

## 🏥 Overview

This Hospital Management System is a console application that provides a complete solution for managing hospital operations. It supports three types of users: **Admin**, **Doctor**, and **Receptionist**, each with specific roles and permissions.

## ✨ Features

### Admin Features
- **Doctor Management**: Add, view, search, update, and delete doctors
- **Receptionist Management**: Add, view, search, update, and delete receptionists
- **Room Management**: Add, view, update status, and delete rooms
- **Statistics**: View comprehensive hospital statistics

### Doctor Features
- View personal appointments
- View upcoming appointments
- View today's appointments
- Update appointment status
- Reschedule appointments

### Receptionist Features
- **Patient Management**: Add, view, search, update, and delete patients
- **Appointment Management**: Create, view, update, and cancel appointments
- **Room Assignment**: Assign and release patients from rooms
- **Patient Search**: Search by name, age range, gender, and special categories (kids, elderly)

## 🏗️ Architecture

The system follows a clean architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                            │
│  (Console App, Menus, Utils)                            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Service Layer                         │
│  (Auth, User, Patient, Appointment, Room, Statistics)   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  Repository Layer                        │
│  (User, Patient, Appointment, Room Repositories)        │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  (Models, Enums)                                        │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Storage Layer                          │
│  (JSON Storage)                                         │
└─────────────────────────────────────────────────────────┘
```

### UML Class Diagram

![UML Diagram](./UML%20diagram.png)
*Figure 1: System Architecture and Class Relationships*

## 📊 Use Cases

The system supports various use cases for different user roles:

### Use Case Diagram

![Use Case Diagram](./Use%20Case%20Diagram.drawio.png)

*Figure 2: System Use Cases and Actor Interactions*

### Key Use Cases:
- **Authentication**: Login for Admin, Doctor, and Receptionist
- **Patient Registration**: Receptionists can register new patients
- **Appointment Scheduling**: Create and manage appointments
- **Room Management**: Assign and manage hospital rooms
- **Staff Management**: Admins can manage doctors and receptionists
- **Statistics Viewing**: View hospital-wide statistics

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- A terminal/command prompt

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Mini-Project-Hospital-Management-System
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d windows
   ```
   
   Or for console output:
   ```bash
   dart run lib/main.dart
   ```

## 💻 Usage

### Default Login Credentials

**Admin Account:**
- Username: `Admin`
- Password: `Admin123`
- User Type: Admin (Option 1)

### Getting Started

1. **Run the application** using the commands above
2. **Select option 1** to login
3. **Choose your user type**:
   - 1 for Admin
   - 2 for Doctor
   - 3 for Receptionist
4. **Enter your credentials**
5. **Navigate through the menus** using the provided options

### Example Workflow

1. **Login as Admin** → Manage Doctors → Add Doctor
2. **Login as Receptionist** → Manage Patients → Add Patient
3. **Login as Receptionist** → Manage Appointments → Create Appointment
4. **Login as Doctor** → View Appointments → Update Status

## 🧪 Testing

The project includes comprehensive test cases covering all major functionalities.

### Run Tests

```bash
flutter test
```

Or:

```bash
dart test test/HBS_test.dart
```

### Test Coverage

The test suite includes 10 test cases covering:

1. ✅ User validation functions
2. ✅ Appointment validation and helper functions
3. ✅ Appointment filtering by patient and doctor
4. ✅ Appointment statistics calculation
5. ✅ Doctor creation and retrieval
6. ✅ Patient creation and retrieval
7. ✅ Patient information updates
8. ✅ Appointment creation
9. ✅ Appointment status updates
10. ✅ Room management (add, assign, release)

## 📁 Project Structure

```
lib/
├── Data/
│   ├── Repositories/      # Data access layer
│   │   ├── user_repository.dart
│   │   ├── patient_repository.dart
│   │   ├── appointment_repository.dart
│   │   └── room_repository.dart
│   └── Storage/            # JSON storage implementation
│       └── json_storage.dart
├── Domain/
│   ├── models/            # Domain models
│   │   ├── admin.dart
│   │   ├── doctor.dart
│   │   ├── receptionist.dart
│   │   ├── patient.dart
│   │   ├── appointment.dart
│   │   ├── room.dart
│   │   └── user.dart
│   └── enums/             # Enumerations
│       ├── gender.dart
│       ├── user_role.dart
│       ├── appointment_status.dart
│       ├── room_type.dart
│       ├── room_status.dart
│       └── shift.dart
├── Service/               # Business logic layer
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── patient_service.dart
│   ├── appointment_service.dart
│   ├── room_service.dart
│   └── statistic_service.dart
└── UI/                    # User interface layer
    ├── console_app.dart
    ├── menus/
    │   ├── main_menu.dart
    │   ├── admin_menu.dart
    │   ├── doctor_menu.dart
    │   └── receptionist_menu.dart
    └── utils/
        └── console_utils.dart
test/
└── HBS_test.dart          # Test suite
```

## 🛠️ Technologies Used

- **Flutter/Dart**: Primary programming language and framework
- **Clean Architecture**: Separation of concerns with layered architecture
- **JSON Storage**: Local data persistence
- **Console UI**: Terminal-based user interface
- **Test Framework**: Dart test package for unit testing

## 📝 Key Components

### Models
- **User Models**: Admin, Doctor, Receptionist (inheriting from base User)
- **Patient**: Patient information and medical history
- **Appointment**: Appointment scheduling and management
- **Room**: Hospital room management

### Services
- **AuthenticationService**: User login and password management
- **UserService**: Doctor and receptionist management
- **PatientService**: Patient CRUD operations and search
- **AppointmentService**: Appointment management and filtering
- **RoomService**: Room assignment and status management
- **StatisticsService**: Hospital-wide statistics

### Repositories
- Data persistence using JSON files
- CRUD operations for all entities
- Data validation and integrity

## 🔐 Security Features

- Password validation (minimum 6 characters)
- Username uniqueness checking
- Role-based access control
- Input validation for all fields

## 📊 Data Storage

The system uses JSON files for data persistence:
- `admins.json`: Admin user data
- `doctors.json`: Doctor information
- `receptionists.json`: Receptionist information
- `patients.json`: Patient records
- `appointments.json`: Appointment data
- `rooms.json`: Room information

## 🤝 Contributing

This is a mini-project for educational purposes. Feel free to fork and enhance!

## 📄 License

This project is for educational use.

---



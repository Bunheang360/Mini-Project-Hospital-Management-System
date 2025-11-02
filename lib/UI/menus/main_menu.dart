import 'dart:io';
import '../../Domain/services/auth_service.dart';
import '../../Domain/enums/user_role.dart';
import '../utils/console_helper.dart';
import '../utils/input_valid_utils.dart';
import 'admin_menu.dart';
import 'receptionist_menu.dart';

class MainMenu {
  final AuthService _authService;
  final AdminMenu _adminMenu;
  final ReceptionistMenu _receptionistMenu;

  MainMenu(this._authService, this._adminMenu, this._receptionistMenu);

  // Display main menu and handle login
  Future<void> show() async {
    while (true) {
      ConsoleHelper.clearScreen();
      ConsoleHelper.printHeader('Hospital Management System');

      print('Welcome! Please select your role:\n');
      ConsoleHelper.printMenu([
        'Login as Admin',
        'Login as Receptionist',
        'Exit',
      ]);

      final choice = InputValidator.readChoice(
        '\nEnter your choice',
        3,
        allowZero: false,
      );

      if (choice == 3) {
        _exitSystem();
        return;
      }

      final role = choice == 1 ? UserRole.admin : UserRole.receptionist;
      await _handleLogin(role);
    }
  }

  // Handle login process
  Future<void> _handleLogin(UserRole role) async {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printHeader('Login - ${role.displayName}');

    final username = InputValidator.readString('Username');
    final password = InputValidator.readString('Password');

    try {
      final user = await _authService.login(username, password);

      if (user == null) {
        ConsoleHelper.printError('Login failed');
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      // Check if user role matches selected role
      if (user.role != role) {
        ConsoleHelper.printError('Invalid role for this user');
        _authService.logout();
        ConsoleHelper.pressEnterToContinue();
        return;
      }

      ConsoleHelper.printSuccess('Login successful!');
      ConsoleHelper.printInfo('Welcome, ${user.username}!');
      await Future.delayed(Duration(seconds: 1));

      // Route to appropriate menu
      if (role == UserRole.admin) {
        await _adminMenu.show();
      } else {
        await _receptionistMenu.show();
      }

      // Logout after menu exits
      _authService.logout();
    } catch (e) {
      ConsoleHelper.printError(e.toString());
      ConsoleHelper.pressEnterToContinue();
    }
  }

  // Exit system
  void _exitSystem() {
    ConsoleHelper.clearScreen();
    ConsoleHelper.printHeader('Thank You!');
    print('Exiting Hospital Management System...');
    print('Goodbye!\n');
    exit(0);
  }
}

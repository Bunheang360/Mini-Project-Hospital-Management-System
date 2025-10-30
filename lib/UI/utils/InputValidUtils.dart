import 'dart:io';

class InputValidator {
  // Read string input with validation
  static String readString(String prompt, {bool allowEmpty = false}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.isEmpty && !allowEmpty) {
        print('✗ Input cannot be empty. Please try again.');
        continue;
      }

      return input;
    }
  }

  // Read integer input with validation
  static int readInt(String prompt, {int? min, int? max}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final number = int.tryParse(input);

      if (number == null) {
        print('✗ Invalid number. Please enter a valid integer.');
        continue;
      }

      if (min != null && number < min) {
        print('✗ Number must be at least $min.');
        continue;
      }

      if (max != null && number > max) {
        print('✗ Number must be at most $max.');
        continue;
      }

      return number;
    }
  }

  // Read double input with validation
  static double readDouble(String prompt, {double? min, double? max}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final number = double.tryParse(input);

      if (number == null) {
        print('✗ Invalid number. Please enter a valid number.');
        continue;
      }

      if (min != null && number < min) {
        print('✗ Number must be at least $min.');
        continue;
      }

      if (max != null && number > max) {
        print('✗ Number must be at most $max.');
        continue;
      }

      return number;
    }
  }

  // Read choice from menu
  static int readChoice(String prompt, int maxChoice) {
    return readInt(prompt, min: 1, max: maxChoice);
  }

  // Read yes/no confirmation
  static bool readConfirmation(String prompt) {
    while (true) {
      stdout.write('$prompt (y/n): ');
      final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

      if (input == 'y' || input == 'yes') {
        return true;
      } else if (input == 'n' || input == 'no') {
        return false;
      } else {
        print('✗ Please enter y or n.');
      }
    }
  }

  // Read email with validation
  static String readEmail(String prompt) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    while (true) {
      final input = readString(prompt);

      if (emailRegex.hasMatch(input)) {
        return input;
      }

      print('✗ Invalid email format. Please try again.');
    }
  }

  // Read phone number with validation
  static String readPhoneNumber(String prompt) {
    final phoneRegex = RegExp(r'^\d{8,15}$');

    while (true) {
      final input = readString(prompt);
      final cleanPhone = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      if (phoneRegex.hasMatch(cleanPhone)) {
        return cleanPhone;
      }

      print('✗ Invalid phone number. Please enter 8-15 digits.');
    }
  }

  // Read date with validation
  static DateTime readDate(String prompt) {
    while (true) {
      stdout.write('$prompt (DD/MM/YYYY): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final parts = input.split('/');

      if (parts.length != 3) {
        print('✗ Invalid format. Use DD/MM/YYYY.');
        continue;
      }

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day == null || month == null || year == null) {
        print('✗ Invalid date values.');
        continue;
      }

      try {
        final date = DateTime(year, month, day);
        return date;
      } catch (e) {
        print('✗ Invalid date. Please try again.');
      }
    }
  }

  // Read datetime with validation
  static DateTime readDateTime(String prompt) {
    while (true) {
      stdout.write('$prompt (DD/MM/YYYY HH:MM): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final parts = input.split(' ');

      if (parts.length != 2) {
        print('✗ Invalid format. Use DD/MM/YYYY HH:MM.');
        continue;
      }

      final dateParts = parts[0].split('/');
      final timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 2) {
        print('✗ Invalid format. Use DD/MM/YYYY HH:MM.');
        continue;
      }

      final day = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (day == null || month == null || year == null ||
          hour == null || minute == null) {
        print('✗ Invalid date/time values.');
        continue;
      }

      try {
        final dateTime = DateTime(year, month, day, hour, minute);
        return dateTime;
      } catch (e) {
        print('✗ Invalid date/time. Please try again.');
      }
    }
  }

  // Read password (with confirmation)
  static String readPassword(String prompt, {bool requireConfirmation = true}) {
    while (true) {
      final password = readString(prompt);

      if (password.length < 6) {
        print('✗ Password must be at least 6 characters.');
        continue;
      }

      if (!requireConfirmation) {
        return password;
      }

      final confirmation = readString('Confirm password');

      if (password == confirmation) {
        return password;
      }

      print('✗ Passwords do not match. Please try again.');
    }
  }
}
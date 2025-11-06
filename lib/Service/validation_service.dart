class ValidationService {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidUsername(String username) {
    return username.length >= 3 && !username.contains(' ');
  }

  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidId(String id) {
    return id.isNotEmpty && id.length >= 3;
  }

  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  static bool isValidCapacity(int capacity) {
    return capacity > 0 && capacity <= 10;
  }
}
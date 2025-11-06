import '../Domain/models/user.dart';
import '../Data/Repositories/user_repository.dart';
import 'validation_service.dart';

class AuthenticationService {
  final UserRepository _userRepository;

  AuthenticationService(this._userRepository);

  User? login(String username, String password) {
    return _userRepository.authenticate(username, password);
  }

  bool isUsernameAvailable(String username) {
    return !_userRepository.isUsernameExists(username);
  }

  bool changePassword(User user, String oldPassword, String newPassword) {
    if (user.password != oldPassword) {
      return false;
    }

    if (!ValidationService.isValidPassword(newPassword)) {
      return false;
    }

    user.password = newPassword;
    return true;
  }
}

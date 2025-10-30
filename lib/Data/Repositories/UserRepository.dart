import '../../Domain/models/User.dart';
import '../Storage/JsonStorage.dart';
import '../JsonConverter/UserConverter.dart';

class UserRepository {
  final JsonStorage _storage;
  final String _fileName = 'users.json';

  UserRepository(this._storage);

  // Get all users (Admins and Receptionists)
  Future<List<User>> getAll() async {
    final jsonList = await _storage.readJsonFile(_fileName);
    return UserConverter.fromJsonList(jsonList);
  }

  // Get user by ID
  Future<User?> getById(String id) async {
    final users = await getAll();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get user by username
  Future<User?> getByUsername(String username) async {
    final users = await getAll();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  // Save (create or update) a user
  Future<void> save(User user) async {
    final users = await getAll();

    // Check if user already exists
    final existingIndex = users.indexWhere((u) => u.id == user.id);

    if (existingIndex != -1) {
      // Update existing user
      users[existingIndex] = user;
    } else {
      // Add new user
      users.add(user);
    }

    final jsonList = UserConverter.toJsonList(users);
    await _storage.writeJsonFile(_fileName, jsonList);
  }

  // Delete user by ID
  Future<bool> delete(String id) async {
    final users = await getAll();
    final initialLength = users.length;

    users.removeWhere((user) => user.id == id);

    if (users.length < initialLength) {
      final jsonList = UserConverter.toJsonList(users);
      await _storage.writeJsonFile(_fileName, jsonList);
      return true;
    }

    return false;
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final user = await getByUsername(username);
    return user != null;
  }

  // Clear all users
  Future<void> clear() async {
    await _storage.clearJsonFile(_fileName);
  }
}

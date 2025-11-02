// lib/data/storage/json_storage.dart

import 'dart:io';
import 'dart:convert';

class JsonStorage {
  final String dataDirectory;

  JsonStorage({this.dataDirectory = 'data'});

  // Get the storage directory path (lib/Data/Storage)
  String _getStorageDirectory() {
    // Get the directory where this file is located
    final scriptPath = Platform.script.toFilePath();
    final File scriptFile = File(scriptPath);

    // Navigate to lib/Data/Storage directory
    // From the script location, go up to find the lib folder
    Directory current = scriptFile.parent;

    // Find the lib directory
    while (current.path != current.parent.path) {
      if (current.path.endsWith('lib')) {
        break;
      }
      current = current.parent;
    }

    // Return path to lib/Data/Storage
    return '${current.path}${Platform.pathSeparator}Data${Platform.pathSeparator}Storage';
  }

  // Ensure data directory exists (not needed since we're using existing lib/Data/Storage)
  Future<void> _ensureDirectoryExists() async {
    final dirPath = _getStorageDirectory();
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  // Get full file path
  String _getFilePath(String fileName) {
    return '${_getStorageDirectory()}${Platform.pathSeparator}$fileName';
  }

  // Read JSON file and return as List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> readJsonFile(String fileName) async {
    await _ensureDirectoryExists();

    final file = File(_getFilePath(fileName));

    // If file doesn't exist, return empty list
    if (!await file.exists()) {
      return [];
    }

    try {
      final contents = await file.readAsString();

      // If file is empty, return empty list
      if (contents.trim().isEmpty) {
        return [];
      }

      final jsonData = jsonDecode(contents);

      // Ensure it's a list
      if (jsonData is List) {
        return jsonData.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      print('Error reading file $fileName: $e');
      return [];
    }
  }

  // Write List<Map<String, dynamic>> to JSON file
  Future<void> writeJsonFile(
    String fileName,
    List<Map<String, dynamic>> data,
  ) async {
    await _ensureDirectoryExists();

    final file = File(_getFilePath(fileName));

    try {
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error writing file $fileName: $e');
      throw Exception('Failed to write to file: $fileName');
    }
  }

  // Clear all data in a file
  Future<void> clearJsonFile(String fileName) async {
    await writeJsonFile(fileName, []);
  }

  // Check if file exists
  Future<bool> fileExists(String fileName) async {
    final file = File(_getFilePath(fileName));
    return await file.exists();
  }

  // Delete a file
  Future<void> deleteFile(String fileName) async {
    final file = File(_getFilePath(fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }
}

import 'dart:convert';
import 'dart:io';

class JsonStorage {
  final String fileName;
  late String filePath;

  JsonStorage(this.fileName) {
    final directory = Directory('lib/data/storage');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    filePath = '${directory.path}/$fileName';
  }

  List<Map<String, dynamic>> read() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return [];
      }
      final contents = file.readAsStringSync();
      if (contents.isEmpty) {
        return [];
      }
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  void write(List<Map<String, dynamic>> data) {
    try {
      final file = File(filePath);
      final jsonString = json.encode(data);
      file.writeAsStringSync(jsonString);
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  void clear() {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('Error clearing file: $e');
    }
  }
}
import 'dart:io';

class ConsoleUtils {
  // Clear the console screen
  static void clearScreen() {
    if (Platform.isWindows) {
      print(Process.runSync("cls", [], runInShell: true).stdout);
    } else {
      print(Process.runSync("clear", [], runInShell: true).stdout);
    }
  }

  // Print a separator line
  static void printSeparator([int length = 50]) {
    print('=' * length);
  }

  // Print a section header
  static void printHeader(String title) {
    printSeparator();
    print(title);
    printSeparator();
  }
}

import 'dart:io';

class ConsoleHelper {
  // Clear console screen
  static void clearScreen() {
    if (Platform.isWindows) {
      // For Windows - use cls command
      print('\x1B[2J\x1B[0;0H'); // ANSI escape codes
      // Alternatively, if above doesn't work:
      // Process.runSync('cmd', ['/c', 'cls'], runInShell: true);
    } else {
      // For Linux/Mac
      print('\x1B[2J\x1B[0;0H'); // ANSI escape codes
      // Alternatively:
      // Process.runSync('clear', [], runInShell: true);
    }
    // Add extra newlines for better spacing
    print('');
  }

  // Clear screen and show a new section (combination function)
  static void clearAndShowSection(String title) {
    clearScreen();
    printHeader(title);
  }

  // Clear screen and show a menu
  static void clearAndShowMenu(String title, List<String> options) {
    clearScreen();
    printHeader(title);
    printMenu(options);
    print('');
  }

  // Print header with border
  static void printHeader(String title) {
    final border = '=' * 60;
    print('\n$border');
    print(title.toUpperCase().padLeft((60 + title.length) ~/ 2));
    print('$border\n');
  }

  // Print section title
  static void printSection(String title) {
    print('\n--- $title ---');
  }

  // Print success message
  static void printSuccess(String message) {
    print('\nSUCCESS: $message');
  }

  // Print error message
  static void printError(String message) {
    print('\ERROR: $message');
  }

  // Print info message
  static void printInfo(String message) {
    print('\nINFO: $message');
  }

  // Print warning message
  static void printWarning(String message) {
    print('\nWARNING: $message');
  }

  // Print menu options
  static void printMenu(List<String> options) {
    for (int i = 0; i < options.length; i++) {
      print('${i + 1}. ${options[i]}');
    }
  }

  // Print divider
  static void printDivider() {
    print('-' * 60);
  }

  // Wait for user to press Enter
  static void pressEnterToContinue() {
    print('\nPress Enter to continue...');
    stdin.readLineSync();
  }

  // Print table header
  static void printTableHeader(List<String> columns, List<int> widths) {
    String header = '';
    for (int i = 0; i < columns.length; i++) {
      header += columns[i].padRight(widths[i]);
    }
    print(header);
    print('-' * header.length);
  }

  // Print table row
  static void printTableRow(List<String> values, List<int> widths) {
    String row = '';
    for (int i = 0; i < values.length; i++) {
      final value = values[i].length > widths[i]
          ? '${values[i].substring(0, widths[i] - 3)}...'
          : values[i];
      row += value.padRight(widths[i]);
    }
    print(row);
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // Format datetime
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // Format time only
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
